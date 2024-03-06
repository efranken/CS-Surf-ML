. ./variables.ps1

foreach ($package in $packages) {
    Write-Host "Installing $package..."
    winget install -e --id $package --location $mlDirectory --silent --accept-source-agreements --accept-package-agreements
}