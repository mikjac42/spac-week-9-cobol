# SPAC Week 9 - COBOL Programming Exercises

This repository contains solutions to COBOL programming exercises 1-9 from `Opgaver.pdf`, as well as an experimental project that exposes a COBOL program through a NestJS Backend.

## Prerequisites

- **GnuCOBOL** installed at `C:\GnuCobol\` (or update paths in `cobbuild.bat`)
- **Node.js** (v16 or higher) for the REST API project
- **npm** (comes with Node.js)

## Repository Structure

```
├── 01_Hello_world/          # Exercise 1
├── 02_Variabler_og_move/    # Exercise 2
├── 03_Loekker_og_strenghaandtering/  # Exercise 3
├── 04_Strukturer/           # Exercise 4
├── 05_Copybooks/            # Exercise 5
├── 06_Laesning_af_fil/      # Exercise 6
├── 07_Skrivning_i_fil/      # Exercise 7
├── 08_Flere_filer/          # Exercise 8
├── 09_Arrays/               # Exercise 9
├── copybooks/               # Shared COBOL copybook files
├── files/                   # Input and output files for exercises
├── rest_api/                # NestJS REST API with COBOL integration
└── cobbuild.bat             # Build helper script for COBOL programs
```

## Building and Running COBOL Programs

### Using the Build Helper Script

The `cobbuild.bat` script simplifies compiling COBOL programs by automatically setting the correct include and library paths.

#### Example: Building and Running Exercise 1 (Hello World)

1. **Compile the program:**
  ```powershell
  .\cobbuild.bat -x .\01_Hello_world\hello.cob -o .\01_Hello_world\hello.exe
  ```

2. **Run the executable:**
   ```powershell
   .\01_Hello_world\hello.exe
   ```

## REST API Project

The `rest_api/` directory contains an experimental project that demonstrates how to integrate COBOL programs with a modern REST API using NestJS.

### Project Overview

- **COBOL Program:** `movie_lookup.cob` - Searches for movies in a CSV dataset
- **NestJS Backend:** Provides REST endpoints that call the COBOL program
- **Dataset:** `movies_dataset.csv` - Sample dataset containing movie information from IMDB

### Building the REST API

1. **Navigate to the rest_api directory:**
   ```powershell
   cd rest_api
   ```

2. **Compile COBOL program:**
   ```powershell
   .\build.bat
   ```

3. **Install Node.js dependencies:**
   ```powershell
   npm install
   ```

### Running the REST API

#### Development Mode (with hot reload for NestJS server):
```powershell
npm run start:dev
```

#### Production Mode:
```powershell
npm run start:prod
```

The server will start on `http://localhost:8080` (or the port configured in `main.ts`).

### Testing the API

Once the server is running, you can test the endpoints:

#### Get Movie by ID:
```powershell
curl http://localhost:8080/movie?id=5
```

Or open in your browser: `http://localhost:8080/movie?id=5`

#### Health Check:
```powershell
curl http://localhost:8080/health
```