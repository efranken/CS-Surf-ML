. ./variables.ps1

# creates steamcmdGui dir
if (-not (Test-Path -Path $steamcmdGuiDirectory -PathType Container)) {
    New-Item -Path $steamcmdGuiDirectory -ItemType Directory
}

# if steamcmdgui zip doesn't exist yet, download and unzip it
# this effectively pins version of steamcmd-gui to 3.1.0.2 since it's hard linked
if (-not (Test-Path -Path $steamcmdGuiZipPath -PathType Leaf)) {
    Invoke-WebRequest -Uri "https://github.com/DioJoestar/SteamCMD-GUI/releases/download/3.1.0.2/SteamCMD.GUI.zip" -OutFile $steamcmdGuiZipPath
}

Expand-Archive -Path $steamcmdGuiZipPath -DestinationPath $steamcmdGuiDirectory -Force
