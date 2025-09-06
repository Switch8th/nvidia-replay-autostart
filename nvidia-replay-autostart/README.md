# NVIDIA Replay Auto-Start

Automatically enables NVIDIA Replay (GeForce Experience) every time you start your PC.

## Overview

This project provides a solution to automatically enable NVIDIA Replay feature on Windows startup. NVIDIA Replay is a feature that continuously records your gameplay, allowing you to save highlights after they happen.

## Features

- Automatically enables NVIDIA Replay on system startup
- Configurable startup delay
- Logging for troubleshooting
- Multiple startup methods (Task Scheduler, Startup folder)

## Requirements

- Windows 10/11
- NVIDIA GeForce Experience installed
- NVIDIA graphics card with Replay support

## Installation

### Prerequisites
- Windows 10/11
- NVIDIA GeForce Experience installed and configured
- NVIDIA graphics card with Replay support (GTX 600 series or newer)
- Administrator privileges for installation

### Quick Install
1. Download or clone this project to your local machine
2. Right-click on `install.bat` and select "Run as administrator"
3. Choose your preferred installation method:
   - **Task Scheduler** (Recommended): Most reliable, runs with system privileges
   - **Startup Folder**: Simple shortcut method
   - **Registry Run Key**: Classic Windows startup method
4. Restart your computer to test the automatic startup

### Manual Installation
If you prefer to set up manually:

#### Method 1: Task Scheduler
```cmd
schtasks /create /tn "NVIDIA Replay Auto-Start" /tr "powershell.exe -ExecutionPolicy Bypass -File 'C:\path\to\enable-nvidia-replay.ps1' -Silent" /sc onstart /delay 0000:30 /rl highest /f
```

#### Method 2: Startup Folder
1. Press `Win + R`, type `shell:startup`, and press Enter
2. Create a shortcut to the PowerShell script in this folder
3. Set the shortcut target to: `powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\enable-nvidia-replay.ps1" -Silent`

#### Method 3: Registry Run Key
```cmd
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "NVIDIA Replay Auto-Start" /d "powershell.exe -ExecutionPolicy Bypass -File 'C:\path\to\enable-nvidia-replay.ps1' -Silent" /f
```

## Usage

### Automatic Operation
Once installed, the script will automatically run every time you start your computer. It will:
1. Wait for the system to fully load (configurable delay)
2. Check if GeForce Experience is running
3. Start GeForce Experience if needed
4. Enable NVIDIA Replay using registry modifications
5. Log all activities for troubleshooting

### Manual Testing
To test the script manually:
```powershell
.\enable-nvidia-replay.ps1
```

With custom parameters:
```powershell
.\enable-nvidia-replay.ps1 -DelaySeconds 5 -Silent
```

### Configuration
Edit `config.json` to customize settings:
- `delaySeconds`: How long to wait before attempting to enable Replay
- `silent`: Whether to suppress console output
- `retryAttempts`: Number of retry attempts if the first try fails
- `logFile`: Path to the log file

### Uninstallation
To remove the auto-start functionality:
1. Right-click on `uninstall.bat` and select "Run as administrator"
2. The script will remove all traces of the auto-start setup

## How It Works

The script uses multiple methods to ensure NVIDIA Replay is enabled:

### Primary Method: Registry Modification
The script directly modifies Windows registry keys that control NVIDIA Replay:
- `IsShadowPlayEnabled`: Main ShadowPlay enable flag
- `IsShadowPlayEnabledUser`: User-level enable flag
- `DwmEnabled`: Desktop Window Manager recording
- `DwmDvrEnabledV1`: DVR functionality
- `DwmEnabledUser`: User-level DWM setting

### Fallback Method: Keyboard Automation
If registry modification fails, the script can simulate the Alt+Z keyboard shortcut to open the GeForce Experience overlay.

### Service Management
The script can optionally restart NVIDIA services to ensure changes take effect immediately.

## Troubleshooting

### Common Issues

#### "GeForce Experience not found"
- **Solution**: Install NVIDIA GeForce Experience from the official NVIDIA website
- **Verify**: Check if the executable exists at `C:\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\`

#### "Registry path not found"
- **Solution**: Run GeForce Experience at least once and configure ShadowPlay/Replay settings
- **Verify**: Open GeForce Experience → Settings → Privacy Control → ensure ShadowPlay is turned on

#### "Script execution policy error"
- **Solution**: Run PowerShell as administrator and execute:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

#### "Access denied" errors
- **Solution**: Ensure you're running the installation script as administrator
- **Alternative**: Use the startup folder method which doesn't require admin privileges

#### Replay still not enabled after restart
- **Check**: Look at the log file (`nvidia-replay-autostart.log`) for error messages
- **Verify**: Manually run the script to see real-time output
- **Test**: Open GeForce Experience and check if Replay is enabled in settings

### Log File Location
By default, logs are saved to `nvidia-replay-autostart.log` in the same directory as the script. Check this file for detailed information about what the script is doing.

### Debug Mode
Run the script without the `-Silent` parameter to see real-time output:
```powershell
.\enable-nvidia-replay.ps1 -DelaySeconds 0
```

## File Structure
```
nvidia-replay-autostart/
├── README.md                    # This documentation
├── enable-nvidia-replay.ps1     # Main PowerShell script
├── config.json                  # Configuration file
├── install.bat                  # Installation script
├── uninstall.bat               # Uninstallation script
└── nvidia-replay-autostart.log # Log file (created when run)
```

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Known Limitations
- The script currently targets GeForce Experience. Future versions may support other NVIDIA software
- Registry modifications may not work with all versions of GeForce Experience
- Some antivirus software may flag the script due to registry modifications

## License

This project is provided as-is for educational and personal use. Use at your own risk.

## Disclaimer

This software is not affiliated with or endorsed by NVIDIA Corporation. GeForce Experience and NVIDIA Replay are trademarks of NVIDIA Corporation.
