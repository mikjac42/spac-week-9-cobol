import { Controller, Get, Query, BadRequestException } from '@nestjs/common';
import { MovieService } from './movie.service';
import { MovieDto } from './dto/movie.dto';

@Controller('movie')
export class MovieController {
  constructor(private readonly movieService: MovieService) {}

  // GET /movie?id={id}
  @Get()
  async getMovie(@Query('id') id: string): Promise<MovieDto> {
    if (!id) {
      throw new BadRequestException('Missing id parameter');
    }

    const movieId = parseInt(id, 10);
    
    if (isNaN(movieId)) {
      throw new BadRequestException('Invalid id parameter');
    }

    const movie = await this.movieService.getMovieById(movieId);
    
    console.log(`Request: GET /movie?id=${movieId}`);
    console.log(`Response: 200 OK - Movie "${movie.title}"\n`);
    
    return movie;
  }
}
