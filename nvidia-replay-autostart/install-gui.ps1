# NVIDIA Replay Auto-Start GUI Installer
# This script provides a graphical interface for installing the automatic startup for NVIDIA Replay
# Replicates the functionality of install.bat with a user-friendly GUI

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to show error message
function Show-ErrorMessage {
    param([string]$Message)
    [System.Windows.Forms.MessageBox]::Show($Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to show success message
function Show-SuccessMessage {
    param([string]$Message)
    [System.Windows.Forms.MessageBox]::Show($Message, "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Function to show info message
function Show-InfoMessage {
    param([string]$Message)
    [System.Windows.Forms.MessageBox]::Show($Message, "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Function to install using Task Scheduler
function Install-TaskScheduler {
    param([string]$ScriptPath)
    
    try {
        $global:statusLabel.Text = "Installing using Task Scheduler..."
        $global:statusLabel.Refresh()
        
        $taskCommand = "powershell.exe -ExecutionPolicy Bypass -File `"$ScriptPath`" -Silent"
        $result = Start-Process -FilePath "schtasks" -ArgumentList @("/create", "/tn", "NVIDIA Replay Auto-Start", "/tr", $taskCommand, "/sc", "onstart", "/delay", "0000:30", "/rl", "highest", "/f") -Wait -PassThru -NoNewWindow
        
        if ($result.ExitCode -eq 0) {
            $global:statusLabel.Text = "Task Scheduler installation completed successfully!"
            return $true
        } else {
            $global:statusLabel.Text = "ERROR: Failed to create scheduled task."
            return $false
        }
    } catch {
        $global:statusLabel.Text = "ERROR: Exception during Task Scheduler installation: $($_.Exception.Message)"
        return $false
    }
}

# Function to install using Startup Folder
function Install-StartupFolder {
    param([string]$ScriptPath)
    
    try {
        $global:statusLabel.Text = "Installing using Startup Folder..."
        $global:statusLabel.Refresh()
        
        $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $shortcutPath = "$startupFolder\NVIDIA Replay Auto-Start.lnk"
        
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$ScriptPath`" -Silent"
        $Shortcut.WindowStyle = 7  # Minimized
        $Shortcut.Save()
        
        $global:statusLabel.Text = "Startup folder installation completed!"
        return $true
    } catch {
        $global:statusLabel.Text = "ERROR: Exception during Startup Folder installation: $($_.Exception.Message)"
        return $false
    }
}

# Function to install using Registry Run Key
function Install-RegistryRun {
    param([string]$ScriptPath)
    
    try {
        $global:statusLabel.Text = "Installing using Registry Run Key..."
        $global:statusLabel.Refresh()
        
        $regCommand = "powershell.exe -ExecutionPolicy Bypass -File `"$ScriptPath`" -Silent"
        $result = Start-Process -FilePath "reg" -ArgumentList @("add", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "/v", "NVIDIA Replay Auto-Start", "/d", $regCommand, "/f") -Wait -PassThru -NoNewWindow
        
        if ($result.ExitCode -eq 0) {
            $global:statusLabel.Text = "Registry installation completed successfully!"
            return $true
        } else {
            $global:statusLabel.Text = "ERROR: Failed to create registry entry."
            return $false
        }
    } catch {
        $global:statusLabel.Text = "ERROR: Exception during Registry installation: $($_.Exception.Message)"
        return $false
    }
}

# Function to handle installation
function Start-Installation {
    $selectedMethod = $global:methodComboBox.SelectedItem
    $scriptPath = Join-Path $PSScriptRoot "enable-nvidia-replay.ps1"
    
    if (-not $selectedMethod) {
        Show-ErrorMessage "Please select an installation method."
        return
    }
    
    # Check if the enable-nvidia-replay.ps1 script exists
    if (-not (Test-Path $scriptPath)) {
        Show-ErrorMessage "Error: enable-nvidia-replay.ps1 not found in the current directory.`n`nPath: $scriptPath"
        return
    }
    
    $global:installButton.Enabled = $false
    $success = $false
    
    switch ($selectedMethod) {
        "Task Scheduler (Recommended)" {
            $success = Install-TaskScheduler -ScriptPath $scriptPath
        }
        "Startup Folder" {
            $success = Install-StartupFolder -ScriptPath $scriptPath
        }
        "Registry Run Key" {
            $success = Install-RegistryRun -ScriptPath $scriptPath
        }
    }
    
    $global:installButton.Enabled = $true
    
    if ($success) {
        $completionMessage = "Installation complete!`nThe NVIDIA Replay auto-start will begin working on next system restart.`n`nTo test manually, run: enable-nvidia-replay.ps1`nTo uninstall, run: uninstall.bat"
        Show-SuccessMessage $completionMessage
        $global:form.Close()
    } else {
        Show-ErrorMessage "Installation failed. Please check the status message and try again."
    }
}

# Check administrator privileges first
if (-not (Test-Administrator)) {
    Show-ErrorMessage "This application requires administrator privileges.`n`nPlease:`n1. Right-click on the script file`n2. Select 'Run as administrator'`n`nOr run PowerShell as administrator and execute the script."
    exit 1
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "NVIDIA Replay Auto-Start Installer"
$form.Size = New-Object System.Drawing.Size(500, 350)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.Icon = [System.Drawing.SystemIcons]::Application

# Create title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(460, 30)
$titleLabel.Text = "NVIDIA Replay Auto-Start Installer"
$titleLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($titleLabel)

# Create separator line
$separatorLabel = New-Object System.Windows.Forms.Label
$separatorLabel.Location = New-Object System.Drawing.Point(20, 55)
$separatorLabel.Size = New-Object System.Drawing.Size(460, 2)
$separatorLabel.BorderStyle = "Fixed3D"
$form.Controls.Add($separatorLabel)

# Create author label
$authorLabel = New-Object System.Windows.Forms.Label
$authorLabel.Location = New-Object System.Drawing.Point(20, 65)
$authorLabel.Size = New-Object System.Drawing.Size(460, 20)
$authorLabel.Text = "Made by Bradley"
$authorLabel.TextAlign = "MiddleCenter"
$authorLabel.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($authorLabel)

# Create admin status label
$adminLabel = New-Object System.Windows.Forms.Label
$adminLabel.Location = New-Object System.Drawing.Point(20, 95)
$adminLabel.Size = New-Object System.Drawing.Size(460, 20)
$adminLabel.Text = "[OK] Running with administrator privileges..."
$adminLabel.ForeColor = [System.Drawing.Color]::Green
$adminLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($adminLabel)

# Create instruction label
$instructionLabel = New-Object System.Windows.Forms.Label
$instructionLabel.Location = New-Object System.Drawing.Point(20, 130)
$instructionLabel.Size = New-Object System.Drawing.Size(460, 20)
$instructionLabel.Text = "Select an installation method:"
$instructionLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($instructionLabel)

# Create dropdown for installation methods
$methodComboBox = New-Object System.Windows.Forms.ComboBox
$methodComboBox.Location = New-Object System.Drawing.Point(20, 160)
$methodComboBox.Size = New-Object System.Drawing.Size(460, 25)
$methodComboBox.DropDownStyle = "DropDownList"
$methodComboBox.Items.AddRange(@(
    "Task Scheduler (Recommended)",
    "Startup Folder", 
    "Registry Run Key"
))
$methodComboBox.SelectedIndex = 0  # Default to recommended option
$form.Controls.Add($methodComboBox)

# Create description label
$descriptionLabel = New-Object System.Windows.Forms.Label
$descriptionLabel.Location = New-Object System.Drawing.Point(20, 195)
$descriptionLabel.Size = New-Object System.Drawing.Size(460, 60)
$descriptionLabel.Text = "Task Scheduler: Most reliable, runs with system privileges, 30-second startup delay`nStartup Folder: Simple shortcut method, user-level privileges`nRegistry Run Key: Classic Windows startup method via registry"
$descriptionLabel.Font = New-Object System.Drawing.Font("Arial", 9)
$form.Controls.Add($descriptionLabel)

# Create install button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(180, 265)
$installButton.Size = New-Object System.Drawing.Size(140, 35)
$installButton.Text = "Install"
$installButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$installButton.BackColor = [System.Drawing.Color]::LightGreen
$installButton.ForeColor = [System.Drawing.Color]::Black
$installButton.Add_Click({ Start-Installation })
$form.Controls.Add($installButton)

# Create status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 310)
$statusLabel.Size = New-Object System.Drawing.Size(460, 20)
$statusLabel.Text = "Ready to install..."
$statusLabel.TextAlign = "MiddleCenter"
$statusLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Italic)
$form.Controls.Add($statusLabel)

# Store form references globally
$global:statusLabel = $statusLabel
$global:methodComboBox = $methodComboBox
$global:installButton = $installButton
$global:form = $form

# Show the form
[System.Windows.Forms.Application]::EnableVisualStyles()
$form.ShowDialog() | Out-Null
