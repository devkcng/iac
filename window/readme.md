# Usage

## Run PowerShell as Administrator.

## The Default Execution Policy is set to restricted, you can see it by running Get-ExecutionPolicy:

```pwsh
Get-ExecutionPolicy
```

## Run Set-ExecutionPolicy like this to switch to the unrestricted mode:

```pwsh
Set-ExecutionPolicy unrestricted
```

## Execute the script by typing:

```pwsh
.\InstallChocoAndApps.ps1
```