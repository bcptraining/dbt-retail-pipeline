@echo off
setlocal EnableDelayedExpansion

REM Generate timestamp for log file name (format: YYYYMMDD-HHMM)
for /f %%x in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd-HHmm')"') do set timestamp=%%x

REM Get uppercase 3-letter day-of-week (e.g. FRI)
for /f %%x in ('powershell -NoProfile -Command "(Get-Date).ToString('ddd').ToUpper()"') do set dow=%%x

REM Define log file path
set logfile=logs\dbt_build_%dow%_%timestamp%.log

REM Go to the dbt project directory (folder where this script lives)
cd /d %~dp0

REM Create logs folder if it doesn't exist
if not exist logs mkdir logs

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
) > "%logfile%" 2>&1

REM Show log file path
echo Log saved to "%logfile%"

pause
