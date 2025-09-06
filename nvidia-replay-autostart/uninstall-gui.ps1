# NVIDIA Replay Auto-Start GUI Uninstaller
# This script provides a graphical interface for removing the automatic startup for NVIDIA Replay
# Replicates the functionality of uninstall.bat with a user-friendly GUI

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

# Function to remove Task Scheduler entry
function Remove-TaskScheduler {
    try {
        $global:statusLabel.Text = "Removing Task Scheduler entry..."
        $global:statusLabel.Refresh()
        
        $result = Start-Process -FilePath "schtasks" -ArgumentList @("/delete", "/tn", "NVIDIA Replay Auto-Start", "/f") -Wait -PassThru -NoNewWindow -RedirectStandardOutput $null -RedirectStandardError $null
        
        if ($result.ExitCode -eq 0) {
            $global:statusLabel.Text = "[OK] Task Scheduler entry removed successfully"
            $global:resultsList.Items.Add("[OK] Task Scheduler entry removed successfully")
            return $true
        } else {
            $global:statusLabel.Text = "[-] No Task Scheduler entry found"
            $global:resultsList.Items.Add("[-] No Task Scheduler entry found")
            return $false
        }
    } catch {
        $global:statusLabel.Text = "[-] No Task Scheduler entry found"
        $global:resultsList.Items.Add("[-] No Task Scheduler entry found")
        return $false
    }
}

# Function to remove Startup folder shortcut
function Remove-StartupFolder {
    try {
        $global:statusLabel.Text = "Removing Startup folder shortcut..."
        $global:statusLabel.Refresh()
        
        $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $shortcutPath = "$startupFolder\NVIDIA Replay Auto-Start.lnk"
        
        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
            $global:statusLabel.Text = "[OK] Startup folder shortcut removed successfully"
            $global:resultsList.Items.Add("[OK] Startup folder shortcut removed successfully")
            return $true
        } else {
            $global:statusLabel.Text = "[-] No Startup folder shortcut found"
            $global:resultsList.Items.Add("[-] No Startup folder shortcut found")
            return $false
        }
    } catch {
        $global:statusLabel.Text = "[-] No Startup folder shortcut found"
        $global:resultsList.Items.Add("[-] No Startup folder shortcut found")
        return $false
    }
}

# Function to remove Registry Run entry
function Remove-RegistryRun {
    try {
        $global:statusLabel.Text = "Removing Registry Run entry..."
        $global:statusLabel.Refresh()
        
        $result = Start-Process -FilePath "reg" -ArgumentList @("delete", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "/v", "NVIDIA Replay Auto-Start", "/f") -Wait -PassThru -NoNewWindow -RedirectStandardOutput $null -RedirectStandardError $null
        
        if ($result.ExitCode -eq 0) {
            $global:statusLabel.Text = "[OK] Registry Run entry removed successfully"
            $global:resultsList.Items.Add("[OK] Registry Run entry removed successfully")
            return $true
        } else {
            $global:statusLabel.Text = "[-] No Registry Run entry found"
            $global:resultsList.Items.Add("[-] No Registry Run entry found")
            return $false
        }
    } catch {
        $global:statusLabel.Text = "[-] No Registry Run entry found"
        $global:resultsList.Items.Add("[-] No Registry Run entry found")
        return $false
    }
}

# Function to handle uninstallation
function Start-Uninstallation {
    $global:uninstallButton.Enabled = $false
    $global:resultsList.Items.Clear()
    
    $global:statusLabel.Text = "Removing all NVIDIA Replay Auto-Start installations..."
    
    # Track if any installations were found
    $foundAny = $false
    
    # Remove all installation methods
    if (Remove-TaskScheduler) { $foundAny = $true }
    if (Remove-StartupFolder) { $foundAny = $true }
    if (Remove-RegistryRun) { $foundAny = $true }
    
    $global:uninstallButton.Enabled = $true
    $global:statusLabel.Text = "Uninstallation complete!"
    
    if ($foundAny) {
        $completionMessage = "Uninstallation complete!`nNVIDIA Replay Auto-Start has been completely removed from your system.`n`nAll startup configurations have been cleared."
    } else {
        $completionMessage = "Uninstallation complete!`nNo NVIDIA Replay Auto-Start installations were found on this system.`n`nThe system was already clean."
    }
    
    Show-SuccessMessage $completionMessage
}

# Check administrator privileges first
if (-not (Test-Administrator)) {
    Show-ErrorMessage "This application requires administrator privileges.`n`nPlease:`n1. Right-click on the script file`n2. Select 'Run as administrator'`n`nOr run PowerShell as administrator and execute the script."
    exit 1
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "NVIDIA Replay Auto-Start Uninstaller"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.Icon = [System.Drawing.SystemIcons]::Application

# Create title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(460, 30)
$titleLabel.Text = "NVIDIA Replay Auto-Start Uninstaller"
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
$instructionLabel.Size = New-Object System.Drawing.Size(460, 40)
$instructionLabel.Text = "This will remove all NVIDIA Replay Auto-Start installations:`nTask Scheduler entries, Startup folder shortcuts, Registry Run keys"
$instructionLabel.Font = New-Object System.Drawing.Font("Arial", 10)
$instructionLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($instructionLabel)

# Create uninstall button
$uninstallButton = New-Object System.Windows.Forms.Button
$uninstallButton.Location = New-Object System.Drawing.Point(180, 185)
$uninstallButton.Size = New-Object System.Drawing.Size(140, 35)
$uninstallButton.Text = "Uninstall All"
$uninstallButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$uninstallButton.BackColor = [System.Drawing.Color]::LightCoral
$uninstallButton.ForeColor = [System.Drawing.Color]::Black
$uninstallButton.Add_Click({ Start-Uninstallation })
$form.Controls.Add($uninstallButton)

# Create results label
$resultsLabel = New-Object System.Windows.Forms.Label
$resultsLabel.Location = New-Object System.Drawing.Point(20, 235)
$resultsLabel.Size = New-Object System.Drawing.Size(460, 20)
$resultsLabel.Text = "Uninstallation Results:"
$resultsLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($resultsLabel)

# Create results listbox
$resultsList = New-Object System.Windows.Forms.ListBox
$resultsList.Location = New-Object System.Drawing.Point(20, 260)
$resultsList.Size = New-Object System.Drawing.Size(460, 80)
$resultsList.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($resultsList)

# Create status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 350)
$statusLabel.Size = New-Object System.Drawing.Size(460, 20)
$statusLabel.Text = "Ready to uninstall..."
$statusLabel.TextAlign = "MiddleCenter"
$statusLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Italic)
$form.Controls.Add($statusLabel)

# Store form references globally
$global:statusLabel = $statusLabel
$global:resultsList = $resultsList
$global:uninstallButton = $uninstallButton
$global:form = $form

# Show the form
[System.Windows.Forms.Application]::EnableVisualStyles()
$form.ShowDialog() | Out-Null
