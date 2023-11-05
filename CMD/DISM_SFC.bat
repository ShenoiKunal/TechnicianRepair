@echo off

rem Set the path to the log file
set log_file=%userprofile%\Desktop\dism_sfc_log.txt

echo Running DISM... > %log_file%
dism /Online /Cleanup-image /Restorehealth >> %log_file% 2>&1
if %errorlevel% NEQ 0 (
    echo ERROR: DISM failed with error code %errorlevel% >> %log_file%
) else (
    echo DISM completed successfully >> %log_file%
)

echo Running SFC... >> %log_file%
sfc /scannow >> %log_file% 2>&1
if %errorlevel% NEQ 0 (
    echo ERROR: SFC failed with error code %errorlevel% >> %log_file%
) else (
    echo SFC completed successfully >> %log_file%
)

echo Done. Results logged to %log_file%

pause
