# Initialize oh-my-posh with your custom theme
oh-my-posh init pwsh --config ~/mytheme.omp.json | Invoke-Expression

# Aliases for Python
Set-Alias python py
Set-Alias python3 py

# Alias for rm -rf (rmrf function)
Set-Alias rm rmrf

# Check if current shell has admin rights
function is-admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Custom sudo function: just warns if not admin
function sudo {
    if (-not (is-admin)) {
        Write-Host "⚠️  This action requires Administrator privileges. Please restart PowerShell as Administrator." -ForegroundColor Yellow
    } else {
        Invoke-Expression ($args -join " ")
    }
}

# rmrf: Recursively and forcefully remove a directory or file, requires admin manually
function rmrf {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (is-admin)) {
        Write-Host "⚠️  rmrf requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Yellow
        return
    }

    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            $_.Attributes = 'Normal'
        }

        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "⚠️  Path '$Path' does not exist." -ForegroundColor Yellow
    }
}
