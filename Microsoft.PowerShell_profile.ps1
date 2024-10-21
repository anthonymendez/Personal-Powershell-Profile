#####################################
# Functions for commands
#####################################

# Install/Update winget, choco, and scoop.
function Setup-Package-Managers {
    Write-Host "Checking if winget is installed."
    $wingetExists = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetExists) {
        Write-Host "winget is not installed. Installing..."

        # From: https://stackoverflow.com/a/75334942
        # get latest download url
        $URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url"
        # download
        Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing        # install
        Add-AppxPackage -Path "Setup.msix"
        # delete file
        Remove-Item "Setup.msix"
    }
    else {
        Write-Host "winget is installed. Updating..."
        winget upgrade winget
    }
  
    Write-Host "Checking if Chocolatey is installed."
    $chocoExists = Get-Command choco -ErrorAction SilentlyContinue
    if (-not $chocoExists) {
        Write-Host "Chocolatey is not installed. Installing..."
        if (Test-Path "$env:ProgramData\chocolatey") {
            Remove-Item -Path "$env:ProgramData\chocolatey" -Recurse -Force
        }
        $chocoInstallCommand = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        Start-Process -FilePath "$env:ProgramFiles\PowerShell\7\pwsh.exe" -Verb RunAs -ArgumentList "-NoProfile", "-Command", "$chocoInstallCommand"
    }
    else {
        Write-Host "Chocolatey is installed. Updating..."
        choco upgrade chocolatey
    }
  
    Write-Host "Checking if Scoop is installed."
    $scoopExists = Get-Command scoop -ErrorAction SilentlyContinue
    if (-not $scoopExists) {
        Write-Host "Scoop is not installed. Installing..."
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    else {
        Write-Host "Scoop is installed. Updating..."
        scoop install git
        scoop update
    }

    Reload-Profile
}

# Installs oh-my-posh, fastfetch, and neovim.
function Setup-Basic-Packages {
    winget install gerardog.gsudo -s winget
    winget install Fastfetch-cli.Fastfetch -s winget
    winget install Neovim.Neovim -s winget

    winget install JanDeDobbeleer.OhMyPosh -s winget
    $ohMyPoshBin = "$HOME\AppData\Local\Programs\oh-my-posh\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "$env:USERNAME")
    # Check if the path is already in the PATH variable
    if ($currentPath -notlike "*$ohMyPoshBin*") {
        # Add the path to the beginning of the PATH variable
        $newPath = "$ohMyPoshBin;$currentPath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
  
        Write-Host "Path added to environment variables. You may need to restart PowerShell or your current terminal session for the changes to take effect."
    }
    else {
        Write-Host "Oh-My-Posh already exists in environment variables."
    }
    Copy-Item "$env:POSH_THEMES_PATH\paradox.omp.json" "$env:POSH_THEMES_PATH\CUSTOM.omp.json"
}

# Setup Powershell again from a backed-up directory.
function Restore-Profile($dir) {
    Setup-Package-Managers
    Validate-Directory($dir)

    # Installing Programs
    Write-Host "Installing Winget Packages."
    winget import -i "$dir/winget_packages.txt" --accept-package-agreements --accept-source-agreements --ignore-unavailable
    Write-Host "Installing Choco Packages."
    choco install -y "$dir/choco_packages.txt"
    Write-Host "Installing Scoop Packages."
    scoop import "$dir/scoop_packages.txt"

    # Folders
    Write-Host "Importing folder configurations."
    Restore-Config 'glzr' 'glzr (e.g. GlazeWM & Zebar)' "$dir/.glzr" "$HOME"
    Restore-Config 'SSH' 'SSH Keys' "$dir/.ssh" "$HOME"
    Restore-Config 'FastFetch' 'FastFetch configuration' "$dir/fastfetch" "$HOME/.config/fastfetch"
    Restore-Config 'Terminal' 'Windows 11 Terminal Settings' "$dir/LocalState" "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

    # Files
    Write-Host "Importing file configs."
    Restore-Config 'Oh-my-Posh' 'Oh-my-Posh Configuration' "$dir/paradox2.omp.json" "$env:POSH_THEMES_PATH/paradox2.omp.json"
    Restore-Config 'Gemini' 'Gemini API Key' "$dir/GeminiApiKey.txt" "$HOME"

    # File Regexes
    Write-Host "Importing file regexes."
    Restore-Config 'Powershell' 'Powershell (PS1) Scripts' "$dir/*.ps1" "$HOME"
    Restore-Config 'Batch' 'Batch Scripts' "$dir/*.bat" "$HOME"
}

# Reload profile.
function Reload-Profile {
    & $PROFILE
}

# Reboot the computer
function Reboot {
    shutdown -r -t 0
}

# Restart explorer.exe
function Restart-Explorer {
    taskkill /F /IM explorer.exe
    Start-Process explorer.exe
}

# Check Settings Sync status.
$SettingsSyncJobName = "Settings Sync"
function Check-Sync {
    Get-Job -Name $SettingsSyncJobName
    Receive-Job -Name $SettingsSyncJobName
}

# Quickly get the total Powershell history.
function pshistory { Get-Content (Get-PSReadlineOption).HistorySavePath }

# yt-dlp alias for getting the wav file.
function yt-dlp-audio($url) { yt-dlp --extract-audio --audio-format wav $url }

# yt-dlp alias to get video as mp4 file.
function yt-dlp-mp4($url) { yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" $url }

# Create a new terminal with admin privileges.
function admin {
    if ($args.Count -gt 0) {
        $argList = "& '$args'"
        Write-Host $argList
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    }
    else {
        Start-Process wt -Verb runAs
    }
}

# Open WinUtil with admin privileges.
function winutil {
    gsudo { Invoke-WebRequest -useb https://christitus.com/win | Invoke-Expression }
}

# Open WinUtil-Dev with admin privileges.
function winutil-dev {
    gsudo { Invoke-WebRequest -useb https://christitus.com/windev | Invoke-Expression }
}

# Aliases for Bash realpath, basename, and dirname
function realpath($path) {
    (Get-Item $path).FullName
}

function basename($path) {
    (Get-Item $path).Name
}

function dirname($path) {
    (Get-Item $path).DirectoryName
}

# Validate the directory to make sure the argument is not null or empty.
function Validate-Directory($dir) {
    if (([string]::IsNullOrEmpty($dir))) {
        throw "No directory provided. Please provide a directory to restore settings from."
    }
    
    if (!(Test-Path -Path $dir)) {
        throw "Directory does not exist. Please provide a valid directory to restore settings from."
    }
}

# Restore the contents of a folder to a particular file. This function overwrites all contents.
function Restore-Folder($from, $to) {
    Validate-Directory($from)
    if (!(Test-Path -Path $to -PathType Container)) {
        New-Item -ItemType Directory -Path $to
    }
    Validate-Directory($to)

    # Get files in folder.
    $files = Get-ChildItem -Path $from -File
    foreach ($file in $files) {
        $sourceFile = $file.FullName
        Restore-Files $sourceFile $to
    }
}

# Restore the contents of a the file(s) to the directory. This function overwrites all contents.
function Restore-Files($from, $to) {
    Validate-Directory($from)
    if (!(Test-Path -Path $to -PathType Container)) {
        New-Item -ItemType Directory -Path $to
    }
    Validate-Directory($to)

    # Copy item. At this point, $from is a regex or file path.
    Copy-Item -Force $from $to
}

# Creates the restoration prompt and handling.
function Restore-Config($configName, $configDesc, $configSourceFolder, $configTargetFolder) {
    $source = Resolve-Path $configSourceFolder
    $target = Resolve-Path $configTargetFolder

    $sourceType = (Test-Path -Path $source -PathType Container) ? 'Folder' : 'File'
    $targetType = (Test-Path -Path $target -PathType Container) ? 'Folder' : 'File'

    $promptTitle = "$configName Restore"
    $promptQuestion = @"
    Restore $configDesc config?
    Restore Source: $sourceType - $source
    Restore Target: $targetType - $target
"@

    $promptChoices = '&Yes', '&No'
    $confirm = $Host.UI.PromptForChoice($promptTitle, $promptQuestion, $promptChoices, 1)
    if ($confirm -eq 0) {
        Write-Host "Restoring $configName files."

        if ($sourceType -eq "Folder") {
            Write-Host "Restoring configuration via Folder method."
            Restore-Folder $source $target
        }
        else {
            Write-Host "Restoring configuration via File method."
            Restore-Files $source $target
        }
    }
    else {
        Write-Host "Skipping $configName files."
    }
}

#####################################
# Aliases
#####################################

# Alias for Gemini CLI.
# https://github.com/reugn/gemini-cli
Set-Alias -Name gchat -Value gemini

# Alias for reload profile
Set-Alias -Name rprofile -Value Reload-Profile

# Alias for Neovim
Set-Alias -Name neovim -Value nvim
Set-Alias -Name vim -Value nvim

# Alias for VSCodium
# https://github.com/VSCodium/vscodium
Set-Alias -Name code -Value codium

# Alias for bashlike find.
Set-Alias -Name gfind -Value "C:\Program Files (x86)\GnuWin32\bin\find.exe"
Set-Alias -Name gnufind -Value "C:\Program Files (x86)\GnuWin32\bin\find.exe"

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin

#####################################
# Variables
#####################################

# Set gemini environment variable
# https://aistudio.google.com/app/apikey
$GEMINI_API_KEY_PATH = "$HOME/GeminiApiKey.txt"
if (Test-Path $GEMINI_API_KEY_PATH) {
    $ENV:GEMINI_API_KEY = Get-Content $GEMINI_API_KEY_PATH
}

# Other environment variables
$ZEBAR = "$HOME/.glzr/zebar/config.yaml"
$ZEBAR_START = "$HOME/.glzr/zebar/start.bat"
$GLAZEWM = "$HOME/.glzr/glazewm/config.yaml"
$FASTFETCH = "$HOME/.config/fastfetch/config.jsonc"
$OH_MY_POSH_THEME_PATH = "$env:POSH_THEMES_PATH\CUSTOM.omp.json"

#######################################################
# Copy Profile & Settings to home directory for syncing
#######################################################
# Copy Processes
Start-Job -Name $SettingsSyncJobName -ScriptBlock {
    # Input Files
    $glzrPath = "$HOME/.glzr"
    $ps1Scripts = "$HOME/*.ps1"
    $batScripts = "$HOME/*.bat"
    $sshFolder = "$HOME/.ssh"
    $fastFetchFolder = "$HOME/.config/fastfetch"
    $w11TerminalSettingsFolder = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

    $ohMyPoshThemePath = "$env:POSH_THEMES_PATH\CUSTOM.omp.json"
    $geminiApiKeyPath = "$HOME/GeminiApiKey.txt"
    
    # Output Dir
    $w11TerminalSyncPath = "$HOME\w11_terminal"
    New-Item -ItemType Directory -Path $w11TerminalSyncPath -Force

    Copy-Item -Force $PROFILE "$w11TerminalSyncPath"
    Copy-Item -Force $ps1Scripts $w11TerminalSyncPath
    Copy-Item -Force $batScripts $w11TerminalSyncPath
    Copy-Item -Force $ohMyPoshThemePath $w11TerminalSyncPath
    Copy-Item -Force $geminiApiKeyPath $w11TerminalSyncPath
    Copy-Item -Force $fastFetchFolder $w11TerminalSyncPath -Recurse
    Copy-Item -Force $w11TerminalSettingsFolder $w11TerminalSyncPath -Recurse
    Copy-Item -Force $sshFolder $w11TerminalSyncPath -Recurse
    Copy-Item -Force $glzrPath $w11TerminalSyncPath -Recurse

    # Remove old packages path
    if (Test-Path "$w11TerminalSyncPath/winget_packages_old.txt") {
        Remove-Item "$w11TerminalSyncPath/winget_packages_old.txt" -Force
    }
    Copy-Item "$w11TerminalSyncPath/winget_packages.txt" "$w11TerminalSyncPath/winget_packages_old.txt"
    Remove-Item "$w11TerminalSyncPath/winget_packages.txt" -Force
    winget export -o "$w11TerminalSyncPath/winget_packages.txt"
    
    choco export -o  "$w11TerminalSyncPath/choco_packages.txt"
    scoop export > "$w11TerminalSyncPath/scoop_packages.txt"
}

#####################################
# Setting up new terminal window.
#####################################

# Clear any output from before :)
Clear-Host

# Init oh-my-posh
$ohMyPoshExe = Get-Command oh-my-posh.exe -ErrorAction SilentlyContinue
if ($ohMyPoshExe) {
    oh-my-posh.exe init pwsh --config "$OH_MY_POSH_THEME_PATH" | Invoke-Expression
}

# Clear and print fastfetch
$fastFetchExe = Get-Command fastfetch.exe -ErrorAction SilentlyContinue
if ($fastFetchExe) {
    fastfetch.exe
}
