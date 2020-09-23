Param (
    [string]$ContextMenuLabel = "Ouvrir un profil Windows Terminal ici",
    [bool]$Uninstall = $false
)

$directoryContextMenu = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\WindowsTerminal"
$backgroundContextMenu = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\WindowsTerminal"
$driveContextMenu = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Drive\shell\WindowsTerminal"
$subMenuRelativePath = "Directory\ContextMenus\WindowsTerminal"
$subMenuRootPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus"
$subMenuPath = "$subMenuRootPath\WindowsTerminal\shell"
$imagesLocation = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState"

if (!(Test-Path -Path $env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe)) {
    Write-Host "Impossible de trouver Windows Terminal. Veuillez installer Windows Terminal avant de réessayer."
    return
}

Write-Host "Suppresion des clés de registres inscrite précédemment."

if (Test-Path -Path $directoryContextMenu) {
    Remove-Item -Recurse -Force -Path $directoryContextMenu
}

if (Test-Path -Path $backgroundContextMenu) {
    Remove-Item -Recurse -Force -Path $backgroundContextMenu
}

if (Test-Path -Path $driveContextMenu) {
    Remove-Item -Recurse -Force -Path $driveContextMenu
}

if (Test-Path -Path $subMenuRootPath) {
    Remove-Item -Recurse -Force -Path $subMenuRootPath
}

if ($Uninstall) {
    return;
}

Write-Host "Récupération des images sur le repository Github Microsoft Terminal"
(New-Object System.Net.WebClient).DownloadFile("https://github.com/microsoft/terminal/raw/master/res/terminal.ico", "$imagesLocation\terminal.ico")

Write-Host "Création des entrées dans le registre."
[void](New-Item -Path $directoryContextMenu -Force)
[void](New-ItemProperty -Path $directoryContextMenu -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRelativePath)
[void](New-ItemProperty -Path $directoryContextMenu -Name Icon -PropertyType String -Value "$imagesLocation\terminal.ico")
[void](New-ItemProperty -Path $directoryContextMenu -Name MUIVerb -PropertyType String -Value $ContextMenuLabel)

[void](New-Item -Path $backgroundContextMenu -Force)
[void](New-ItemProperty -Path $backgroundContextMenu -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRelativePath)
[void](New-ItemProperty -Path $backgroundContextMenu -Name Icon -PropertyType String -Value "$imagesLocation\terminal.ico")
[void](New-ItemProperty -Path $backgroundContextMenu -Name MUIVerb -PropertyType String -Value $ContextMenuLabel)

[void](New-Item -Path $driveContextMenu -Force)
[void](New-ItemProperty -Path $driveContextMenu -Name ExtendedSubCommandsKey -PropertyType String -Value $subMenuRelativePath)
[void](New-ItemProperty -Path $driveContextMenu -Name Icon -PropertyType String -Value "$imagesLocation\terminal.ico")
[void](New-ItemProperty -Path $driveContextMenu -Name MUIVerb -PropertyType String -Value $ContextMenuLabel)

Write-Host "Récupération des profils de Windows Terminal"

$content = (Get-Content "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json") -replace '^\s*\/\/.*' | Out-String
$profiles = (ConvertFrom-Json -InputObject $content).profiles.list

$profiles | ForEach-Object {
    $name = $_.name
    $iconPath = $_.icon
    $guid = $_.guid
    $commandLine = $_.commandline
    $source = $_.source

    $profilePath = "$subMenuPath\$guid"

    if (!$_.hidden) {
        [void](New-Item -Force -Path $profilePath)
        [void](New-Item -Force -Path "$profilePath\command")

        if (!$null -eq $source) {
            switch ($source) {
                "Windows.Terminal.Wsl" {
                    Copy-Item -Path "$PSScriptRoot\assets\icons\wsl.ico" -Destination "$imagesLocation/wsl.ico"
                    
                    $iconPath = "$imagesLocation\wsl.ico"
                }
                "Windows.Terminal.Azure" {
                    Copy-Item -Path "$PSScriptRoot\assets\icons\azure.ico" -Destination "$imagesLocation\azure.ico"

                    $iconPath = "$imagesLocation\azure.ico"
                }
                Default { 
                    $iconPath = "$imagesLocation\terminal.ico"
                }
            }
        }

        if (!$null -eq $commandline) {
            switch ($commandLine) {
                "cmd.exe" {
                    $iconPath = (Get-Command cmd.exe).Definition
                }
                "powershell.exe" {
                    $iconPath = (Get-Command powershell.exe).Definition
                }
            }
        }

        if (!($null -eq $name)) {
            [void](New-ItemProperty -Path $profilePath -Name "MUIVerb" -PropertyType String -Value "$name")

            [void](New-ItemProperty -Path "$profilePath\command" -Name "(default)" -PropertyType String -Value "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe -p `"$name`" -d `"%V`"")

            [void](New-ItemProperty -Path $profilePath -Name Icon -PropertyType String -Value $iconPath)
        }       
    }
}