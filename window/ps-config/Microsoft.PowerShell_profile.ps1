# Initialize oh-my-posh with your custom theme
if (-not (Get-Command 'oh-my-posh' -ErrorAction SilentlyContinue)) {
    Write-Host "❌ oh-my-posh is not installed. Please install it first." -ForegroundColor Red
} else {
    oh-my-posh init pwsh --config ~/mytheme.omp.json | Invoke-Expression
}

# Aliases for Python
Set-Alias python py
Set-Alias python3 py