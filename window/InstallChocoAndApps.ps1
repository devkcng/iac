# Ensure the script runs with administrator rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    exit
}

# Ensure execution policy allows script execution
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "Execution policy is Restricted. Updating to AllSigned for security." -ForegroundColor Yellow
    Set-ExecutionPolicy AllSigned -Scope Process -Force
}

# Install Chocolatey if it is not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey installation failed!" -ForegroundColor Red
        exit
    }
    Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
}
else {
    Write-Host "Chocolatey is already installed." -ForegroundColor Yellow
}

# Define the list of applications to install
$appList = @(
    "googlechrome",      # Google Chrome
    "powershell-core",   # PowerShell Core
    "vscode",            # Visual Studio Code
    "notepadplusplus",   # Notepad++
    "7zip",              # 7-Zip
    "git",               # Git
    "warp",              # Warp
    "vlc",               # VLC media player
    "flow-launcher",     # Flow Launcher
    "telegram.install",  # Telegram Desktop
    "lightshot.install" # Lightshot
)

# Install applications using Chocolatey
foreach ($app in $appList) {
    Write-Host "Installing $app..." -ForegroundColor Cyan
    choco install $app -y --ignore-checksums
    if ($LASTEXITCODE -ne 0) {
        Write-Host "$app installation failed!" -ForegroundColor Red
    } else {
        Write-Host "$app installed successfully!" -ForegroundColor Green
    }
}

Write-Host "All applications have been processed. Script complete!" -ForegroundColor Green
