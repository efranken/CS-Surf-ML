. ./variables.ps1

# Check if the directory exists
if (Test-Path $gitPath -PathType Container) {
    # If it exists, delete it
    Remove-Item -Path $gitPath -Recurse -Force
    Write-Host "Directory '$gitPath' existed and has been deleted."
} else {
    # If it doesn't exist, write a message to the host
    Write-Host "Directory '$gitPath' does not exist yet."
}

# Download the ZIP archive
git clone $gitUrl $gitPath


Write-Host "Repository contents downloaded to $targetFolder"