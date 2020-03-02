# WindowsTerminalOpenHere

Powershell script allowing to add in the context menu an entry "**Open a Windows Terminal profil here**".

## Feature

- Parse Windows Terminal profiles.json to add your profiles in the context menu.

# Prerequirements

* [PowerShell configuration for script execution](https://go.microsoft.com/fwlink/?LinkID=135170)


## How to use

1. Clone this repository `https://github.com/thibaultmaudet/WindowsTerminalOpenHere.git` or download [WindowsTerminal-OpenHere.ps1](https://github.com/thibaultmaudet/WindowsTerminalOpenHere/blob/master/WindowsTerminal-OpenHere.ps1)
2. Run Windows Powershell and run `WindowsTerminal-OpenHere.ps1`

## Commandline arguments

Argument|Type|Default value
---|---|---
ContextMenuLabel|string|Ouvrir un profil Windows Terminal ici
