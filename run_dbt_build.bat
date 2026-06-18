@echo off
setlocal enabledelayedexpansion

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
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format ''yyyyMMdd''"') do set "YYYYMMDD=%%i"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format ''HHmm''"') do set "HHMM=%%i"

REM ---- Ensure logs directory exists ----
if not exist "logs" (
    mkdir "logs"
)

set LOGFILE=logs\dbt_build_%ENV%_%YYYYMMDD%_%HHMM%.log

echo =======================================
echo Starting dbt build workflow...
echo Environment: %ENV%
echo Log file: %LOGFILE%
echo =======================================

REM ---- Run dbt ----
dbt build --target %ENV% > "%LOGFILE%" 2>&1

REM ---- Capture dbt exit code before endlocal ----
set "DBT_EXIT_CODE=%ERRORLEVEL%"

echo =======================================
echo Build complete for environment: %ENV%
echo Log saved to: %LOGFILE%
echo =======================================

endlocal & exit /b %DBT_EXIT_CODE%
