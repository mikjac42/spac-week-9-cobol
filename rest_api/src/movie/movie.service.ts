import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { spawn } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { Movie } from './movie.interface';

@Injectable()
export class MovieService {
  private readonly idFilePath = path.join(process.cwd(), 'movie_id.txt');
  private readonly resultFilePath = path.join(process.cwd(), 'movie_result.json');
  private readonly cobolExecutable = path.join(process.cwd(), 'movie_lookup.exe');

  // Lookup movie by ID using COBOL program
  async getMovieById(id: number): Promise<Movie> {
    if (isNaN(id) || id < 0) {
      throw new BadRequestException('Invalid movie ID');
    }

    
    try {
      // Cleanup temp files before processing, in case temp files were left behind due to crash or error
      this.cleanupFile(this.idFilePath);
      this.cleanupFile(this.resultFilePath);

      // Pass ID to COBOL program via ID temp file, execute it, and read result from result temp file
      fs.writeFileSync(this.idFilePath, id.toString());
      await this.executeCobolProgram();
      const movie = this.readMovieResult();

      // Cleanup temp files
      this.cleanupFile(this.idFilePath);
      this.cleanupFile(this.resultFilePath);

      if (!movie) {
        throw new NotFoundException(`Movie with ID ${id} not found`);
      }

      return movie;
    } catch (error) {
      // Cleanup on error
      this.cleanupFile(this.idFilePath);
      this.cleanupFile(this.resultFilePath);

      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }

      throw new Error(`Error processing movie request: ${error.message}`);
    }
  }

  // Execute the COBOL program as a child process, return promise that resolves on completion
  private executeCobolProgram(): Promise<void> {
    return new Promise((resolve, reject) => {
      const cobolProcess = spawn(this.cobolExecutable);

      cobolProcess.on('close', (code) => {
        if (code === 0) {
          resolve();
        } else {
          reject(new Error(`COBOL program exited with code ${code}`));
        }
      });

      cobolProcess.on('error', (error) => {
        reject(new Error(`Failed to execute COBOL program: ${error.message}`));
      });
    });
  }

  // Read and parse the movie result from result temp file
  private readMovieResult(): Movie | null {
    if (!fs.existsSync(this.resultFilePath)) {
      return null;
    }

    try {
      const jsonData = fs.readFileSync(this.resultFilePath, 'utf8');
      this.cleanupFile(this.resultFilePath);

      if (!jsonData.trim()) {
        return null;
      }

      return JSON.parse(jsonData) as Movie;
    } catch (error) {
      console.error('Error reading movie result:', error);
      return null;
    }
  }

  // Delete file at given path if it exists, for temp file cleanup
  private cleanupFile(filePath: string): void {
    try {
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (error) {
      console.error(`Error cleaning up file ${filePath}:`, error);
    }
  }
}
