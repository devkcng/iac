# Initialize Oh My Posh 
if (-not (Get-Command 'oh-my-posh' -ErrorAction SilentlyContinue)) {
    Write-Host "❌ oh-my-posh is not installed. Please install it first." -ForegroundColor Red
} else {
    $theme = "$HOME\tokyonight_storm.omp.json"
    oh-my-posh init pwsh --config $theme | Invoke-Expression
}

# Python aliases
Set-Alias python py
Set-Alias python3 py
Set-Alias pip3 pip