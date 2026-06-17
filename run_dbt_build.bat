@echo off
setlocal EnableDelayedExpansion

REM =======================================
REM Generate timestamp and day-of-week
REM =======================================

for /f %%x in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd-HHmm')"') do set timestamp=%%x
for /f %%x in ('powershell -NoProfile -Command "(Get-Date).ToString('ddd').ToUpper()"') do set dow=%%x

REM =======================================
REM Ensure logs directory exists
REM =======================================

if not exist logs mkdir logs

REM =======================================
REM Retain only the 5 most recent log files
REM =======================================

pushd logs

set count=0
for /f "delims=" %%F in ('dir /b /o-d *.log') do (
    set /a count+=1
    if !count! GTR 5 (
        del "%%F"
    )
)

popd

REM =======================================
REM Define log file path
REM =======================================

set logfile=logs\dbt_build_%dow%_%timestamp%.log

REM =======================================
REM Move to script directory
REM =======================================

cd /d "%~dp0"

REM =======================================
REM Run dbt build and capture output
REM =======================================

(
echo =======================================
echo Starting dbt build workflow ...
echo Project: DBT-RETAIL-PIPELINE
echo Timestamp: %timestamp%
echo =======================================
echo.

dbt build

echo.
echo =======================================
echo dbt build finished.
echo =======================================
echo.
) > "%logfile%" 2>&1

REM =======================================
REM Capture exit code AFTER the block
REM =======================================

set "dbt_exit_code=%ERRORLEVEL%"

REM =======================================
REM Show log file path
REM =======================================

echo Log saved to "%logfile%"

REM =======================================
REM Pause only when running locally
REM =======================================

if "%CI%"=="" pause

exit /b "%dbt_exit_code%"
