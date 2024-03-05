. ./variables.ps1

# Set the URL of the Git repository
$repoUrl = "https://github.com/efranken/CS-Surf-ML"

# Set the target folder where you want to download the repository
$targetFolder = $gitDirectory

# Create a temporary folder for downloading and extracting
$tempFolder = Join-Path $env:TEMP "GitRepoDownload"

# Ensure the temporary folder exists, and if not, create it
if (-not (Test-Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Download the ZIP archive
$zipFile = Join-Path $tempFolder "repo.zip"
Invoke-WebRequest -Uri $repoUrl -OutFile $zipFile

# Extract the contents of the ZIP archive
Expand-Archive -Path $zipFile -DestinationPath $targetFolder -Force

# Clean up: Remove the temporary folder
Remove-Item -Path $tempFolder -Recurse -Force

Write-Host "Repository contents downloaded to $targetFolder"