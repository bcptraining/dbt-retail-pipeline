@echo off
setlocal enabledelayedexpansion
s 
REM ---- Ensure script runs from its own directory ----
pushd "%~dp0"

REM =======================================
REM Multi‑Environment dbt Build Script
REM Usage:  run_dbt_build.bat dev
REM         run_dbt_build.bat qa
REM         run_dbt_build.bat prod
REM =======================================

REM ---- Validate input ----
if "%1"=="" (
    echo ERROR: No environment specified.
    echo Usage: run_dbt_build.bat dev ^| qa ^| prod
    exit /b 1
)

set ENV=%1

REM ---- Validate allowed environments ----
if /I "%ENV%"=="dev"  goto ok
if /I "%ENV%"=="qa"   goto ok
if /I "%ENV%"=="prod" goto ok

echo ERROR: Invalid environment "%ENV%".
echo Allowed values: dev, qa, prod
exit /b 1

:ok

REM ---- Timestamp for logs (locale-independent) ----

for /f "tokens=1-2 delims==" %%a in ('wmic os get LocalDateTime /value') do (
    if "%%a"=="LocalDateTime" set ldt=%%b
)

set YYYYMMDD=%ldt:~0,8%
set HHMM=%ldt:~8,4%


REM ---- Ensure logs directory exists ----
if not exist "logs" (
    mkdir "logs"
)

set LOGFILE=logs\dbt_build_%ENV%_%YYYYMMDD%_%HHMM%.log

REM ---- Retain only the most recent 5 log files per environment ----
for /f "skip=5 delims=" %%F in (
    'dir /b /a-d /o-d "logs\dbt_build_%ENV%_*.log" 2^>nul'
) do (
    echo Deleting old log: logs\%%F
    del "logs\%%F"
)

echo =======================================
echo Starting dbt build workflow...
echo Environment: %ENV%
echo Log file: %LOGFILE%
echo =======================================

REM ---- Run dbt ----
dbt build --target %ENV% > "%LOGFILE%" 2>&1

REM ---- Capture dbt exit code before endlocal ----
set "DBT_EXIT_CODE=%ERRORLEVEL%"

REM ---- Restore the caller's working directory ----
popd

echo =======================================
echo Build complete for environment: %ENV%
echo Log saved to: %LOGFILE%
echo =======================================

endlocal & exit /b %DBT_EXIT_CODE%
