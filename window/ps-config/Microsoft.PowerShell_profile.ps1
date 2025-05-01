# Initialize oh-my-posh with your custom theme
oh-my-posh init pwsh --config ~/mytheme.omp.json | Invoke-Expression

# Aliases for Python
Set-Alias python py
Set-Alias python3 py

# Alias for rm-rf (force-delete-folder function)
Set-Alias rm-rf force-delete-folder

# Check if current shell has admin rights
function is-admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Custom sudo function
function sudo {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$args
    )

    $command = $args -join " "

    # Append pause-like prompt to keep terminal open
    $script = @"
$command

Read-Host -Prompt '✅ Done. Press Enter to close'
"@

    $tempScript = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".ps1")
    Set-Content -Path $tempScript -Value $script -Encoding UTF8

    try {
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File `"$tempScript`""
    } catch {
        Write-Host "❌ Failed to elevate privilege or user denied UAC prompt." -ForegroundColor Red
    }
}


function force-delete-folder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )

    if (-not (Test-Path $FolderPath)) {
        Write-Host "⚠️ Folder '$FolderPath' does not exist." -ForegroundColor Yellow
        return
    }

    $script = @"
# Force normalize all attributes
Get-ChildItem -Path '$FolderPath' -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    if (\$_.Attributes -ne 'Normal') { 
        \$_.Attributes = 'Normal' 
    }
}
# Then remove
Remove-Item -Path '$FolderPath' -Recurse -Force -ErrorAction SilentlyContinue

# Keep window open
Read-Host -Prompt '✅ Done. Press Enter to close'
"@

    $tempFile = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".ps1")
    Set-Content -Path $tempFile -Value $script -Encoding UTF8

    try {
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File `"$tempFile`""
    } catch {
        Write-Host "❌ UAC elevation failed or was denied." -ForegroundColor Red
    }
}