@echo off
REM Build script for COBOL Movie Lookup with Node.js Express

echo ===================================
echo Building COBOL Movie Lookup Program
echo ===================================
echo.

REM Set GnuCOBOL paths
set COBINC=C:\GnuCobol\include
set COBLIB=C:\GnuCobol\lib
set COB_CONFIG_DIR=C:\GnuCobol\config
set COB_COPY_DIR=C:\GnuCobol\copy

echo Compiling COBOL movie lookup program...
cobc -x -o movie_lookup.exe movie_lookup.cob -I"%COBINC%" -L"%COBLIB%"
if errorlevel 1 (
    echo.
    echo Build failed!
    exit /b 1
)

echo.
echo ===================================
echo Build Complete!
echo ===================================
echo.
echo COBOL program compiled successfully.
echo.
echo Next steps:
echo   1. Install Node.js dependencies:
echo      cd rest_api
echo      npm install
echo.
echo   2. Start the server:
echo      npm start
echo.
echo   3. Test the API:
echo      curl http://localhost:8080/movie?id=5
echo.
