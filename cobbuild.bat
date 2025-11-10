@echo off
REM Wrapper til GnuCOBOL på Windows

REM Sætter include- og lib-stier automatisk
set COBINC=C:\GnuCobol\include
set COBLIB=C:\GnuCobol\lib

REM Yderligere konfigurations- og kopimapper
set COB_CONFIG_DIR=C:\GnuCobol\config
set COB_COPY_DIR=C:\GnuCobol\copy

REM Kald cobc med de rigtige flags
echo Compiling with: cobc -I"%COBINC%" -L"%COBLIB%" %*
cobc -I"%COBINC%" -L"%COBLIB%" %*
if errorlevel 1 (
    echo Compilation failed!
) else (
    echo Compilation successful!
)
