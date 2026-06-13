@echo off
setlocal EnableDelayedExpansion

REM Create logs folder if it doesn't exist
if not exist logs mkdir logs

REM Generate timestamp for log file name (format: YYYYMMDD-HHMMSS)
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
  set mm=%%a
  set dd=%%b
  set yyyy=%%c
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
  set hh=%%a
  set nn=%%b
)

REM Zero-pad month, day, hour, minute
if 1%mm% LSS 110 set mm=0%mm%
if 1%dd% LSS 110 set dd=0%dd%
if 1%hh% LSS 110 set hh=0%hh%
if 1%nn% LSS 110 set nn=0%nn%

set timestamp=%yyyy%%mm%%dd%-%hh%%nn%

REM Get uppercase 3-letter day-of-week (e.g. FRI)
for /f %%x in ('powershell -NoProfile -Command "(Get-Date).ToString('ddd').ToUpper()"') do set dow=%%x

REM Define log file path
set logfile=logs\dbt_build_%dow%_%timestamp%.log

REM Go to the dbt project directory
cd %~dp0

REM Run dbt build and save output to log file
(
echo =======================================
echo Starting dbt build workflow ...
echo Project: DBT-RETAIL-PIPELINE
echo =======================================
echo.

dbt build

echo.
echo =======================================
echo dbt build finished.

echo Exit code: !ERRORLEVEL!

echo =======================================
echo.
) > %logfile% 2>&1

REM Show log file path
echo Log saved to %logfile%

pause
