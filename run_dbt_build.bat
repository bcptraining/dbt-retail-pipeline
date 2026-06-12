@echo off
REM Create logs folder if it doesn't exist
if not exist logs mkdir logs

REM Generate timestamp for log file name (format: YYYYMMDD-HHMMSS)
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
  set mm=%%a
  set dd=%%b
  set yyyy=%%c
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
  set hh=%%a
  set nn=%%b
)
set timestamp=%yyyy%%mm%%dd%-%hh%%nn%

REM Define log file path
set logfile=logs\dbt_build_%timestamp%.log

REM Go to the dbt project directory
cd C:\Users\coryp\repos\dbt-retail-pipeline

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
echo Exit code: %ERRORLEVEL%
echo =======================================
echo.
) > %logfile% 2>&1

REM Show log file path
echo Log saved to %logfile%

pause