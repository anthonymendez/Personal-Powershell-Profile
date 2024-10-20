# Personal-Powershell-Profile

This is my personal powershell profile that I use regularly.

I decided to setup this Repo in case anyone else finds this useful.

## Installing on a Fresh Install

1. Open up the Terminal application.
1. Allow PowerShell to run scripts.
   ```PowerShell
   Set-ExecutionPolicy Unrestricted -Scope CurrentUser
   ```
1. Create PowerShell profile if it doesn't exist. This will overwrite it if it doesn't exist.
   ```PowerShell
   New-Item -Path (Split-Path -Path $PROFILE -Parent) -ItemType Directory -Force | Out-Null; New-Item -Path $PROFILE -ItemType File -Force | Out-Null
   ```
1. Copy my PowerShell profile into your profile.
   ```PowerShell
   Invoke-WebRequest https://raw.githubusercontent.com/anthonymendez/Personal-Powershell-Profile/refs/heads/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
   ```
1. Restart or reload your Terminal.
   ```PowerShell
   & $PROFILE
   ```
1. At this point, you'll likely see an error come up. **This is expected.**
   ![{6E7AC942-7A74-4E2E-9956-3595419A5F24}](https://github.com/user-attachments/assets/8b033255-7a02-4a51-95a4-a846a5d97680)
1. Run the Setup Package Mangers profile command. This will go through and install Winget, Chocolatey, and Scoop.
   ```PowerShell
   Setup-Package-Managers
   ```
1. Customize the profile and make it your own! I have several automated commands that run and backup config files I use regularly. Some sections you should customize:
   * `Setup-Basic-Packages` - Installs oh-my-posh, FastFetch, Neovim, and gsudo. You may want your own essential programs here.
   * `Restore-Profile` - Function that restores my configuration files based on a given folder.
   * `Aliases` - Common aliases I use for certain programs.
   * `Variables` - Common variables I use for quick access.
   * `Start-Job -Name $SettingsSyncJobName -ScriptBlock` - Backs up your settings to the folder `$HOME\w11_terminal`.
   * `Setting up new terminal window.` - Clears previous output, initializes oh-my-posh, and prints out fastfetch.

## Functions

### Reload-Profile

Reloads the powershell profile in place.

### Check-Sync

Check the status of the settings sync that occurs on each new terminal session or `Reload-Profile`.

### pshistory

Prints out the full history of Powershell. Similar to `cat .bash_history`.

### yt-dlp-audio

Basically an "alias" to easily get the `wav` file of videos.

### Validate-Directory

Checks if the provided path is null, empty, or if it exists.

### Restore-Folder - TO BE IMPLEMENTED

Writes the folder contents of `$from` to `$to` folder.

### Restore-Files - TO BE IMPLEMENTED

Writes the file contents of `$from` to `$to` folder. `$from` can be a regex path.

### Restore-Config

Handles prompting to restore the configuration for a given path/file/file regex to the given destination/target directory.

Example: `Restore-Config 'glzr' 'glzr (e.g. GlazeWM & Zebar)' "$dir/.glzr" "$HOME"`

![{5DA3EFC3-C350-4D89-A4B8-1A52C1C34134}](https://github.com/user-attachments/assets/f42615f1-97e1-4ea4-9549-881a7e6b7eec)

### Restore-Profile - TO BE FINISHED

Performs the full restoration process given the source directory.

## Aliases

| Alias    | Original Command | Notes                                |
|----------|------------------|--------------------------------------|
| gchat    | gemini           | https://github.com/reugn/gemini-cli  |
| rprofile | Reload-Profile   |                                      |
| neovim   | nvim             |                                      |
| vim      | nvim             |                                      |
| code     | codium           | https://hithub.com/VSCodium/vscodium |

## Variables

| Variable               | Value |
|------------------------|-------|
| $GEMINI_API_KEY_PATH   | `$HOME/GeminiApiKey.txt` |
| $ENV:GEMINI_API_KEY       | `Get-Content $GEMINI_API_KEY_PATH` |
| $ZEBAR                 | `$HOME/.glzr/zebar/config.yaml` |
| $ZEBAR_START           | `$HOME/.glzr/zebar/start.bat` |
| $GLAZEWM               | `$HOME/.glzr/glazewm/config.yaml` |
| $FASTFETCH             | `$HOME/.config/fastfetch/config.jsonc` |
| $OH_MY_POSH_THEME_PATH | `$env:POSH_THEMES_PATH\paradox2.omp.json` |

## Settings Sync

Starts a background process to copy various configurations and settings to a destination directory for backup. I have Google Drive installed on my computer so I've setup the destination folder to be backed up there.

The following folders and files are backed up:
* Powershell Profile
* PS1 Scripts in `$HOME`.
* Batch scripts in `$HOME`.
* oh-my-posh theme file.
* The Gemini API Key file.
* My FastFetch config folder.
* Windows 11 Terminal settings folder.
* SSH folder.
* glzr (GlazeWM, Zebar) config folder.
* List of installed winget packages.
* List of installed choco packages.

## New Terminal Window Output

Clears output window incase previous commands, inits oh-my-posh with my custom theme, 

![{E8E2ED1B-FC48-4E9F-AA26-740465BDCA9B}](https://github.com/user-attachments/assets/d68d8f70-f7f0-46f7-af0a-0295afdf9a23)
