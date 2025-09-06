@echo off
REM NVIDIA Replay Auto-Start Uninstaller
REM This script removes the automatic startup for NVIDIA Replay

title NVIDIA Replay Auto-Start Uninstaller

echo ========================================
echo NVIDIA Replay Auto-Start Uninstaller
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo ERROR: This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo Removing all NVIDIA Replay Auto-Start installations...
echo.

REM Remove Task Scheduler entry
echo Removing Task Scheduler entry...
schtasks /delete /tn "NVIDIA Replay Auto-Start" /f >nul 2>&1
if %errorLevel% == 0 (
    echo - Task Scheduler entry removed successfully
) else (
    echo - No Task Scheduler entry found
)

REM Remove Startup folder shortcut
echo Removing Startup folder shortcut...
set startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
if exist "%startupFolder%\NVIDIA Replay Auto-Start.lnk" (
    del "%startupFolder%\NVIDIA Replay Auto-Start.lnk"
    echo - Startup folder shortcut removed successfully
) else (
    echo - No Startup folder shortcut found
)

REM Remove Registry Run entry
echo Removing Registry Run entry...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "NVIDIA Replay Auto-Start" /f >nul 2>&1
if %errorLevel% == 0 (
    echo - Registry Run entry removed successfully
) else (
    echo - No Registry Run entry found
)

echo.
echo Uninstallation complete!
echo NVIDIA Replay Auto-Start has been completely removed from your system.
echo.
pause
