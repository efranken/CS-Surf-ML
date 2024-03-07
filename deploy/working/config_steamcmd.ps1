. ./variables.ps1

# Creates both $mlDirectory and $steamcmdDirectory
if (-not (Test-Path -Path $steamcmdDirectory -PathType Container)) {
    New-Item -Path $steamcmdDirectory -ItemType Directory
}

# creates steamcmdGui dir
if (-not (Test-Path -Path $steamcmdGuiDirectory -PathType Container)) {
    New-Item -Path $steamcmdGuiDirectory -ItemType Directory
}

# if the steamcmdZip doesn't exist yet, get it and unzip it
if (-not (Test-Path -Path $steamcmdZipPath -PathType Leaf)) {
    Invoke-WebRequest -Uri $steamcmdURL -OutFile $steamcmdZipPath
}

Expand-Archive -Path $steamcmdZipPath -DestinationPath $steamcmdDirectory -Force

# start steamcmd, login anonymous, update 232330 (css server), wait for it to finish
Start-Process -FilePath $steamcmdExePath -ArgumentList "+force_install_dir $steamcmdInstallPath +login anonymous +app_update 232330 +quit" -NoNewWindow -Wait

# clone github repo
git clone $gitUrl $mlDirectory

# move testing $map into the newly created steamcmd path
if (Test-Path $mapSourcePath -PathType Leaf) {
    $destinationDir = Split-Path $mapDestinationPath
    if (-not (Test-Path $destinationDir -PathType Container)) {
        New-Item -ItemType Directory -Path $destinationDir -Force
    }
    Move-Item -Path $mapSourcePath -Destination $mapDestinationPath -Force
    Write-Host "map file moved successfully."
} else {
    Write-Host "map file not found. Please make sure it exists."
}

# # if steamcmdgui zip doesn't exist yet, download and unzip it
# # this effectively pins version of steamcmd-gui to 3.1.0.2 since it's hard linked
# if (-not (Test-Path -Path $steamcmdGuiZipPath -PathType Leaf)) {
#     Invoke-WebRequest -Uri "https://github.com/DioJoestar/SteamCMD-GUI/releases/download/3.1.0.2/SteamCMD.GUI.zip" -OutFile $steamcmdGuiZipPath
# }

# Expand-Archive -Path $steamcmdGuiZipPath -DestinationPath $steamcmdGuiDirectory -Force

start-sleep 300

#next step is to download repo and map file