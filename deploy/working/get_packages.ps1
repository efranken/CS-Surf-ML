. ./variables.ps1

foreach ($package in $packages) {
    Write-Host "Installing $package..."
    winget install -e --id $package --silent --accept-source-agreements --accept-package-agreements
}

# allows "psql" to work in command line
setx /M PATH "$($env:path);C:\Program Files\PostgreSQL\16\bin;"

# reload path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 