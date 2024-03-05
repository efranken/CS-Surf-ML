$mlDirectory = "C:\ml"

$gitDirectory = Join-Path -Path $mlDirectory -ChildPath "git_repo"

$steamcmdDirectory = Join-Path -Path $mlDirectory -ChildPath "steamcmd"
$steamcmdInstallPath = Join-Path -Path $mlDirectory -ChildPath "steamcmd_downloads"
$steamcmdZipPath = Join-Path -Path $steamcmdDirectory -ChildPath "steamcmd.zip"
$steamcmdExePath = Join-Path -Path $steamcmdDirectory -ChildPath "steamcmd.exe"

$mapSourcePath = "$mlDirectory\etc\aa_surf_time_test.bsp"
$mapDestinationPath = "$steamcmdInstallPath\cstrike\maps\aa_surf_time_test.bsp"