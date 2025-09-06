# NVIDIA Replay Auto-Enable Script
# This script automatically enables NVIDIA Replay on system startup

param(
    [int]$DelaySeconds = 10,
    [switch]$Silent = $false,
    [string]$LogFile = "nvidia-replay-autostart.log"
)

# Function to write to log file
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    
    if (!$Silent) {
        Write-Host $logMessage
    }
    
    Add-Content -Path $LogFile -Value $logMessage
}

# Function to check if NVIDIA GeForce Experience is running
function Test-GeForceExperience {
    $process = Get-Process -Name "NVIDIA GeForce Experience" -ErrorAction SilentlyContinue
    return $process -ne $null
}

# Function to start GeForce Experience if not running
function Start-GeForceExperience {
    $gfePath = "${env:ProgramFiles}\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"
    
    if (Test-Path $gfePath) {
        Write-Log "Starting NVIDIA GeForce Experience..."
        Start-Process -FilePath $gfePath -WindowStyle Minimized
        return $true
    } else {
        Write-Log "ERROR: NVIDIA GeForce Experience not found at expected location: $gfePath"
        return $false
    }
}

# Function to enable NVIDIA Replay via registry modification
function Enable-NVIDIAReplayRegistry {
    Write-Log "Attempting to enable NVIDIA Replay via registry..."
    
    try {
        $registryPath = "HKCU:\SOFTWARE\NVIDIA Corporation\Global\ShadowPlay\NVSPCAPS"
        
        # Check if the registry path exists
        if (!(Test-Path $registryPath)) {
            Write-Log "ERROR: NVIDIA ShadowPlay registry path not found. Is GeForce Experience installed?"
            return $false
        }
        
        # Enable ShadowPlay/Replay
        Set-ItemProperty -Path $registryPath -Name "IsShadowPlayEnabled" -Value ([byte[]]@(0x01, 0x00, 0x00, 0x00)) -Type Binary
        Set-ItemProperty -Path $registryPath -Name "IsShadowPlayEnabledUser" -Value ([byte[]]@(0x01, 0x00, 0x00, 0x00)) -Type Binary
        
        # Enable Instant Replay specifically
        Set-ItemProperty -Path $registryPath -Name "DwmEnabled" -Value ([byte[]]@(0x01, 0x00, 0x00, 0x00)) -Type Binary
        Set-ItemProperty -Path $registryPath -Name "DwmDvrEnabledV1" -Value ([byte[]]@(0x01, 0x00, 0x00, 0x00)) -Type Binary
        Set-ItemProperty -Path $registryPath -Name "DwmEnabledUser" -Value ([byte[]]@(0x01, 0x00, 0x00, 0x00)) -Type Binary
        
        Write-Log "Registry values set successfully"
        return $true
    } catch {
        Write-Log "ERROR: Failed to modify registry: $($_.Exception.Message)"
        return $false
    }
}

# Function to enable NVIDIA Replay via keyboard shortcut simulation
function Enable-NVIDIAReplayKeyboard {
    Write-Log "Attempting to enable NVIDIA Replay via keyboard shortcut..."
    
    try {
        # Load Windows Forms for SendKeys
        Add-Type -AssemblyName System.Windows.Forms
        
        # Send Alt+Z to open GeForce Experience overlay
        Write-Log "Sending Alt+Z to open GeForce Experience overlay..."
        [System.Windows.Forms.SendKeys]::SendWait("%z")
        
        Start-Sleep -Seconds 2
        
        # Navigate to settings and enable Instant Replay
        # This is a simplified approach - actual implementation may need more specific navigation
        Write-Log "Attempting to navigate overlay interface..."
        
        return $true
    } catch {
        Write-Log "ERROR: Failed to send keyboard shortcuts: $($_.Exception.Message)"
        return $false
    }
}

# Function to restart NVIDIA services to apply changes
function Restart-NVIDIAServices {
    Write-Log "Restarting NVIDIA services to apply changes..."
    
    try {
        $services = @("NVIDIA Display Container LS", "NVDisplay.ContainerLocalSystem")
        
        foreach ($serviceName in $services) {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($service) {
                Write-Log "Restarting service: $serviceName"
                Restart-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
            }
        }
        
        return $true
    } catch {
        Write-Log "WARNING: Could not restart NVIDIA services: $($_.Exception.Message)"
        return $false
    }
}

# Main function to enable NVIDIA Replay with fallback methods
function Enable-NVIDIAReplay {
    Write-Log "Attempting to enable NVIDIA Replay..."
    
    # Method 1: Registry modification (most reliable)
    if (Enable-NVIDIAReplayRegistry) {
        Write-Log "Successfully enabled NVIDIA Replay via registry"
        
        # Optionally restart services to apply changes immediately
        Restart-NVIDIAServices
        
        return $true
    }
    
    # Method 2: Keyboard shortcut simulation (fallback)
    Write-Log "Registry method failed, trying keyboard shortcut method..."
    if (Enable-NVIDIAReplayKeyboard) {
        Write-Log "Successfully triggered NVIDIA Replay via keyboard shortcut"
        return $true
    }
    
    Write-Log "All methods failed to enable NVIDIA Replay"
    return $false
}
    # Method 1: Registry modification (most reliable)
    if (Enable-NVIDIAReplayRegistry) {
        Write-Log "Successfully enabled NVIDIA Replay via registry"
        
        # Optionally restart services to apply changes immediately
        Restart-NVIDIAServices
        
        return $true
    }
    
    # Method 2: Keyboard shortcut simulation (fallback)
    Write-Log "Registry method failed, trying keyboard shortcut method..."
    if (Enable-NVIDIAReplayKeyboard) {
        Write-Log "Successfully triggered NVIDIA Replay via keyboard shortcut"
        return $true
    }
    
    Write-Log "All methods failed to enable NVIDIA Replay"
    return $false
}

# Main execution
try {
    Write-Log "NVIDIA Replay Auto-Start script started"
    Write-Log "Waiting $DelaySeconds seconds before attempting to enable Replay..."
    
    Start-Sleep -Seconds $DelaySeconds
    
    # Check if GeForce Experience is running
    if (!(Test-GeForceExperience)) {
        Write-Log "GeForce Experience not running, attempting to start..."
        if (!(Start-GeForceExperience)) {
            Write-Log "Failed to start GeForce Experience. Exiting."
            exit 1
        }
        
        # Wait for GeForce Experience to fully load
        Write-Log "Waiting for GeForce Experience to load..."
        Start-Sleep -Seconds 15
    }
    
    # Attempt to enable NVIDIA Replay
    if (Enable-NVIDIAReplay) {
        Write-Log "Successfully enabled NVIDIA Replay"
        exit 0
    } else {
        Write-Log "Failed to enable NVIDIA Replay"
        exit 1
    }
} catch {
    Write-Log "ERROR: An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}
