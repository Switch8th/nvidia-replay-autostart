# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

NVIDIA Replay Auto-Start is a Windows automation project that automatically enables NVIDIA Replay (GeForce Experience) on system startup. The project uses PowerShell scripting with multiple fallback mechanisms to ensure reliable operation across different Windows configurations.

## Architecture

### Core Components

- **Main Script (`enable-nvidia-replay.ps1`)**: PowerShell script that handles the primary logic for enabling NVIDIA Replay
- **Configuration (`config.json`)**: JSON configuration file containing settings, paths, and method preferences
- **Installation System**: Batch scripts that provide multiple installation methods (Task Scheduler, Startup folder, Registry)

### Key Architecture Patterns

**Multi-Method Approach**: The system implements a primary/fallback pattern:
1. **Primary Method**: Direct Windows Registry modification for reliability
2. **Fallback Method**: Keyboard automation using Alt+Z shortcut simulation
3. **Service Management**: Optional NVIDIA service restart to apply changes immediately

**Configuration-Driven Design**: All settings are externalized to `config.json`, including:
- Timing parameters (delay, retry attempts)
- File paths for GeForce Experience executable
- Method preferences and fallback strategies

**Logging Framework**: Centralized logging system that supports both console output and file logging with timestamps.

## Common Development Commands

### Testing and Debugging
```powershell
# Test the main script manually with debug output
.\enable-nvidia-replay.ps1

# Test with custom parameters
.\enable-nvidia-replay.ps1 -DelaySeconds 5 -Silent

# Test without delay for immediate debugging
.\enable-nvidia-replay.ps1 -DelaySeconds 0
```

### Installation and Management
```cmd
# Install the auto-start functionality (requires admin privileges)
# Right-click and "Run as administrator"
install.bat

# Remove all auto-start configurations
# Right-click and "Run as administrator"  
uninstall.bat
```

### Registry Operations for Development
```powershell
# Check current NVIDIA Replay registry settings
Get-ItemProperty -Path "HKCU:\SOFTWARE\NVIDIA Corporation\Global\ShadowPlay\NVSPCAPS"

# Manually test registry modifications
Set-ItemProperty -Path "HKCU:\SOFTWARE\NVIDIA Corporation\Global\ShadowPlay\NVSPCAPS" -Name "IsShadowPlayEnabled" -Value ([byte[]]@(0x01, 0x00, 0x00, 0x00)) -Type Binary
```

### Process and Service Management
```powershell
# Check if GeForce Experience is running
Get-Process -Name "NVIDIA GeForce Experience" -ErrorAction SilentlyContinue

# Check NVIDIA services status
Get-Service -Name "NVIDIA Display Container LS", "NVDisplay.ContainerLocalSystem"

# Restart NVIDIA services manually
Restart-Service -Name "NVIDIA Display Container LS" -Force
```

## Configuration Management

The `config.json` file controls all operational parameters:

- **settings.delaySeconds**: System startup delay before attempting Replay enablement
- **settings.retryAttempts**: Number of retry attempts on failure
- **paths**: GeForce Experience executable locations for different installation types
- **methods**: Primary/fallback method configuration and keyboard shortcut settings

## Development Considerations

### Registry Key Targets
The script modifies specific Windows Registry keys under `HKCU:\SOFTWARE\NVIDIA Corporation\Global\ShadowPlay\NVSPCAPS`:
- `IsShadowPlayEnabled`: Main enable flag
- `IsShadowPlayEnabledUser`: User-level enable flag  
- `DwmEnabled`, `DwmDvrEnabledV1`, `DwmEnabledUser`: Desktop Window Manager recording settings

### Error Handling Strategy
The codebase implements comprehensive error handling with:
- Try-catch blocks around all critical operations
- Detailed logging for troubleshooting
- Graceful fallbacks between different enablement methods
- Exit codes for integration with Windows Task Scheduler

### Installation Methods
Three installation approaches are supported, each with different privilege requirements and reliability characteristics:
1. **Task Scheduler**: Most reliable, runs with system privileges, 30-second startup delay
2. **Startup Folder**: Simple shortcut method, user-level privileges
3. **Registry Run Key**: Classic Windows startup method via registry

## File Structure and Dependencies

```
nvidia-replay-autostart/
├── enable-nvidia-replay.ps1     # Main PowerShell script (198 lines)
├── config.json                  # Configuration file
├── install.bat                  # Installation script with method selection
├── uninstall.bat               # Cleanup script
├── README.md                    # User documentation
└── nvidia-replay-autostart.log # Runtime log file (generated)
```

### External Dependencies
- **Windows 10/11**: Required operating system
- **NVIDIA GeForce Experience**: Must be installed and configured
- **PowerShell**: Uses System.Windows.Forms assembly for keyboard automation
- **Windows Registry**: Direct manipulation of NVIDIA registry keys
- **Windows Services**: Optional service restart functionality

### Log File Analysis
Runtime logs are saved to `nvidia-replay-autostart.log` with timestamped entries. Key log patterns indicate:
- Script initialization and parameter handling
- GeForce Experience process detection and startup
- Registry modification success/failure
- Fallback method activation
- Service restart operations

## Windows-Specific Implementation Notes

The codebase is tightly integrated with Windows systems:
- Uses Windows Registry for persistent configuration changes
- Leverages Windows Task Scheduler for reliable startup execution
- Implements Windows service management for immediate effect application
- Uses .NET System.Windows.Forms for keyboard simulation

When modifying the registry manipulation logic, ensure proper binary value formatting using `[byte[]]` arrays for NVIDIA's expected data types.
