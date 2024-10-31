# Personal-Powershell-Profile

This is my personal powershell profile that I use regularly.

I decided to setup this Repo in case anyone else finds this useful.

## Installing on a Fresh Install

1. Open up the Terminal application.
1. Update and make PowerShell 7 the default.

   My profile script uses syntax only compatible with PowerShell 7. Windows comes with PowerShell 5 by default. The command below references Chris Titus Tech's [winutil](https://github.com/ChrisTitusTech/winutil) Invoke-WPFTweakPS7 function.

   This script installs PowerShell 7.

   1. Installs PowerShell 7
   2. Starts a new PowerShell 7 session that will set PowerShell 7 as the default.
   3. Closes the original Terminal session.

   ```PowerShell
   # Allows us to run PowerShell scripts.
   Set-ExecutionPolicy Unrestricted -Scope CurrentUser
   Invoke-WebRequest https://raw.githubusercontent.com/anthonymendez/Personal-Powershell-Profile/refs/heads/main/Scripts/Setup-PowerShell7.ps1 | Invoke-Expression
   ```

1. Download my PowerShell profile!

   ```PowerShell
   Invoke-WebRequest https://raw.githubusercontent.com/anthonymendez/Personal-Powershell-Profile/refs/heads/main/Scripts/Pull-PowerShell7.ps1 | Invoke-Expression
   ```

1. Restart the Terminal, now we'll setup/upgrade the Package Managers (winget, choco, scoop). Afterwards, we install our basic packages (gsudo, fastfetch, neovim, ohmyposh). We reload after each operation.

   ```PowerShell
   Invoke-WebRequest https://raw.githubusercontent.com/anthonymendez/Personal-Powershell-Profile/refs/heads/main/Scripts/Run-Setup.ps1 | Invoke-Expression
   ```

1. Customize the profile and make it your own!

## Functions

### Reload-Profile

Reloads the PowerShell profile in place, ensuring that all configurations are reloaded.
### Check-Sync

Checks the status of the settings sync that occurs on each new terminal session or `Reload-Profile`, providing feedback on any issues.

### pshistory

Prints out the full history of PowerShell commands executed during the current session, similar to how `cat .bash_history` works in Bash.
### yt-dlp-audio

An alias for easily downloading the audio file (in WAV format) from videos using `yt-dlp`.
### Validate-Directory

Checks if the provided path is null, empty, or does not exist. This helps prevent errors when trying to perform operations on non-existent directories.
### Restore-Folder - TO BE IMPLEMENTED

Writes the folder contents of `$from` to `$to` folder, recursively copying all files and subdirectories.
### Restore-Files - TO BE IMPLEMENTED

Writes the file contents of `$from` to `$to` folder. If `$from` is a regex path, it will match and copy all matching files.

### Restore-Config

Handles prompting to restore the configuration for a given path/file/file regex to the given destination/target directory. This includes backup functionality to ensure that no data is lost during the restoration process.

Example: `Restore-Config 'glzr' 'glzr (e.g. GlazeWM & Zebar)' "$dir/.glzr" "$HOME"`

![{5DA3EFC3-C350-4D89-A4B8-1A52C1C34134}](https://github.com/user-attachments/assets/f42615f1-97e1-4ea4-9549-881a7e6b7eec)

### Restore-Profile - TO BE FINISHED

Performs the full restoration process given the source directory. This includes checking for and handling any dependencies, ensuring that all configurations are restored correctly.

## Aliases

| Alias    | Original Command | Notes                                |
| -------- | ---------------- | ------------------------------------ |
| gchat    | gemini           | https://github.com/reugn/gemini-cli  |
| rprofile | Reload-Profile   |                                      |
| neovim   | nvim             |                                      |
| vim      | nvim             |                                      |
| code     | codium           | https://hithub.com/VSCodium/vscodium |

## Variables

| Variable               | Value                                     |
| ---------------------- | ----------------------------------------- |
| $GEMINI_API_KEY_PATH   | `$HOME/GeminiApiKey.txt`                  |
| $ENV:GEMINI_API_KEY    | `Get-Content $GEMINI_API_KEY_PATH`        |
| $ZEBAR                 | `$HOME/.glzr/zebar/config.yaml`           |
| $ZEBAR_START           | `$HOME/.glzr/zebar/start.bat`             |
| $GLAZEWM               | `$HOME/.glzr/glazewm/config.yaml`         |
| $FASTFETCH             | `$HOME/.config/fastfetch/config.jsonc`    |
| $OH_MY_POSH_THEME_PATH | `$env:POSH_THEMES_PATH\paradox2.omp.json` |

## Settings Sync

Starts a background process to copy various configurations and settings to a destination directory for backup. I have Google Drive installed on my computer so I've setup the destination folder to be backed up there.

The following folders and files are backed up:

- Powershell Profile
- PS1 Scripts in `$HOME`.
- Batch scripts in `$HOME`.
- oh-my-posh theme file.
- The Gemini API Key file.
- My FastFetch config folder.
- Windows 11 Terminal settings folder.
- SSH folder.
- glzr (GlazeWM, Zebar) config folder.
- List of installed winget packages.
- List of installed choco packages.

## New Terminal Window Output

Clears output window incase previous commands, inits oh-my-posh with my custom theme,

![{E8E2ED1B-FC48-4E9F-AA26-740465BDCA9B}](https://github.com/user-attachments/assets/d68d8f70-f7f0-46f7-af0a-0295afdf9a23)
