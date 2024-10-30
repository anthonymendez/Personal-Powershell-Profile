# Create directory where the PowerShell profile should be.
New-Item -Path (Split-Path -Path $PROFILE -Parent) -ItemType Directory -Force | Out-Null
# Create the PowerShell profile file.
New-Item -Path $PROFILE -ItemType File -Force | Out-Null

# Download my PowerShell profile.
Invoke-WebRequest https://raw.githubusercontent.com/anthonymendez/Personal-Powershell-Profile/refs/heads/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE