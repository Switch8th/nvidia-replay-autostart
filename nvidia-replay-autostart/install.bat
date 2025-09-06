@echo off
REM NVIDIA Replay Auto-Start Installation Script
REM This script sets up the automatic startup for NVIDIA Replay

title NVIDIA Replay Auto-Start Installer

echo ========================================
echo NVIDIA Replay Auto-Start Installer
echo ========================================
echo.
echo Made by Bradley
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

echo.
echo Available installation methods:
echo 1. Task Scheduler (Recommended)
echo 2. Startup Folder
echo 3. Registry Run Key
echo.

set /p choice="Select installation method (1-3): "

if "%choice%"=="1" goto :task_scheduler
if "%choice%"=="2" goto :startup_folder
if "%choice%"=="3" goto :registry_run
echo Invalid choice. Exiting.
pause
exit /b 1

:task_scheduler
echo.
echo Installing using Task Scheduler...
REM Create scheduled task to run at startup
schtasks /create /tn "NVIDIA Replay Auto-Start" /tr "powershell.exe -ExecutionPolicy Bypass -File \"%~dp0enable-nvidia-replay.ps1\" -Silent" /sc onstart /delay 0000:30 /rl highest /f
if %errorLevel% == 0 (
    echo Task Scheduler installation completed successfully!
) else (
    echo ERROR: Failed to create scheduled task.
)
goto :end

:startup_folder
echo.
echo Installing using Startup Folder...
REM Create shortcut in startup folder
set startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
powershell.exe -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%startupFolder%\NVIDIA Replay Auto-Start.lnk'); $Shortcut.TargetPath = 'powershell.exe'; $Shortcut.Arguments = '-ExecutionPolicy Bypass -File \"%~dp0enable-nvidia-replay.ps1\" -Silent'; $Shortcut.WindowStyle = 7; $Shortcut.Save()"
echo Startup folder installation completed!
goto :end

:registry_run
echo.
echo Installing using Registry Run Key...
REM Add registry entry for startup
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "NVIDIA Replay Auto-Start" /d "powershell.exe -ExecutionPolicy Bypass -File \"%~dp0enable-nvidia-replay.ps1\" -Silent" /f
if %errorLevel% == 0 (
    echo Registry installation completed successfully!
) else (
    echo ERROR: Failed to create registry entry.
)
goto :end

:end
echo.
echo Installation complete!
echo The NVIDIA Replay auto-start will begin working on next system restart.
echo.
echo To test manually, run: enable-nvidia-replay.ps1
echo To uninstall, run: uninstall.bat
echo.
pause
