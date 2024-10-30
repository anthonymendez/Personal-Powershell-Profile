# Install PowerShell 7 via winget
winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements

# Create Terminal Settings file if it doesn't exist
$settingsPath = Resolve-Path "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
New-Item -Path (Split-Path -Path $settingsPath -Parent) -ItemType Directory -Force | Out-Null
New-Item -Path $settingsPath -ItemType File -Force | Out-Null

# Set up the command to make PowerShell 7 our new default shell
$command = "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ChrisTitusTech/winutil/refs/heads/main/functions/public/Invoke-WPFTweakPS7.ps1')); Invoke-WPFTweakPS7 -action PS7"

# Start new PowerShell 7 terminal
Start-Process -FilePath "$env:ProgramFiles\PowerShell\7\pwsh.exe" -ArgumentList "-NoExit", "-Command", $command

exit
