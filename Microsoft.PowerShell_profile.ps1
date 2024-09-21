#####################################
# Functions for commands
#####################################

# Reload profile.
function Reload-Profile {
    & $PROFILE
}

# Check Settings Sync status.
$SettingsSyncJobName = "Settings Sync"
function Check-Sync {
    Get-Job -Name $SettingsSyncJobName
    Receive-Job -Name $SettingsSyncJobName
}

# Quickly get the total Powershell history.
function pshistory { Get-Content (Get-PSReadlineOption).HistorySavePath }

# yt-dlp alias for getting the wav file from a youtube video.
function yt-dlp-audio($url) { yt-dlp --extract-audio --audio-format wav $url }

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
    throw "TO BE IMPLEMENTED"

    Validate-Directory($from)
    Validate-Directory($to)
}

# Restore the contents of a the file(s) to the directory. This function overwrites all contents.
function Restore-Files($from, $to) {
    throw "TO BE IMPLEMENTED"

    Validate-Directory($from)
    Validate-Directory($to)
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

# Setup Powershell again from a backed-up directory.
function Restore-Profile($dir) {
    Validate-Directory($dir)

    Restore-Config 'glzr' 'glzr (e.g. GlazeWM & Zebar)' "$dir/.glzr" "$HOME"
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
$ENV:GEMINI_API_KEY = Get-Content $GEMINI_API_KEY_PATH

# Other environment variables
$ZEBAR = "$HOME/.glzr/zebar/config.yaml"
$ZEBAR_START = "$HOME/.glzr/zebar/start.bat"
$GLAZEWM = "$HOME/.glzr/glazewm/config.yaml"
$FASTFETCH = "$HOME/.config/fastfetch/config.jsonc"
$OH_MY_POSH_THEME_PATH = "$env:POSH_THEMES_PATH\paradox2.omp.json"

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

    $ohMyPoshThemePath = "$env:POSH_THEMES_PATH\paradox2.omp.json"
    $geminiApiKeyPath = "$HOME/GeminiApiKey.txt"
    
    # Output Dir
    $w11TerminalSyncPath = "$HOME\w11_terminal"

    Copy-Item -Force $PROFILE "$w11TerminalSyncPath"
    Copy-Item -Force $ps1Scripts $w11TerminalSyncPath
    Copy-Item -Force $batScripts $w11TerminalSyncPath
    Copy-Item -Force $ohMyPoshThemePath $w11TerminalSyncPath
    Copy-Item -Force $geminiApiKeyPath $w11TerminalSyncPath
    Copy-Item -Force $fastFetchFolder $w11TerminalSyncPath -Recurse
    Copy-Item -Force $w11TerminalSettingsFolder $w11TerminalSyncPath -Recurse
    Copy-Item -Force $sshFolder $w11TerminalSyncPath -Recurse
    Copy-Item -Force $glzrPath $w11TerminalSyncPath -Recurse
    winget export -o "$w11TerminalSyncPath/winget_packages.txt"
    choco export -o  "$w11TerminalSyncPath/choco_packages.txt"
}

#####################################
# Setting up new terminal window.
#####################################

# Clear any output from before :)
Clear-Host

# Init oh-my-posh
oh-my-posh.exe init pwsh --config "$OH_MY_POSH_THEME_PATH" | Invoke-Expression

# Clear and print fastfetch
fastfetch.exe --packages-disabled ''
