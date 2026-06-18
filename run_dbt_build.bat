@echo off
setlocal enabledelayedexpansion

REM =======================================
REM Multi‑Environment dbt Build Script
REM Usage:  dbt_build.bat dev
REM         dbt_build.bat qa
REM         dbt_build.bat prod
REM =======================================

REM ---- Validate input ----
if "%1"=="" (
    echo ERROR: No environment specified.
    echo Usage: dbt_build.bat dev ^| qa ^| prod
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

REM ---- Timestamp for logs ----
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do (
    set YYYYMMDD=%%c%%a%%b
)
for /f "tokens=1-2 delims=: " %%a in ("%time%") do (
    set HHMM=%%a%%b
)

set LOGFILE=logs\dbt_build_%ENV%_%YYYYMMDD%_%HHMM%.log

echo =======================================
echo Starting dbt build workflow...
echo Environment: %ENV%
echo Log file: %LOGFILE%
echo =======================================

REM ---- Run dbt ----
dbt build --target %ENV% > "%LOGFILE%" 2>&1


echo =======================================
echo Build complete for environment: %ENV%
echo Log saved to: %LOGFILE%
echo =======================================

endlocal
