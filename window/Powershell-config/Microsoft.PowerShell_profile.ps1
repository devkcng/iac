# Initialize oh-my-posh with your custom theme
oh-my-posh init pwsh --config ~/mytheme.omp.json | Invoke-Expression

# Aliases for Python
Set-Alias python py
Set-Alias python3 py

# Custom sudo function to run commands as Administrator
function sudo {
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", "$args"
}
