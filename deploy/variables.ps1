$packages = @(
    "Git.Git",
    "Python.Python.3.9",
    "PostgreSQL.PostgreSQL",
    "Valve.Steam"
)

$mlDirectory = "C:\ML"

$steamcmdDirectory = Join-Path -Path $mlDirectory -ChildPath "steamcmd"
$steamcmdInstallPath = Join-Path -Path $mlDirectory -ChildPath "steamcmd_downloads"
$steamcmdZipPath = Join-Path -Path $steamcmdDirectory -ChildPath "steamcmd.zip"
$steamcmdExePath = Join-Path -Path $steamcmdDirectory -ChildPath "steamcmd.exe"
$steamcmdURL = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"

$steamcmdGuiDirectory = Join-Path -Path $mlDirectory -ChildPath "steamcmd-gui"
$steamcmdGuiZipPath = Join-Path -Path $steamcmdGuiDirectory -ChildPath "steamcmd-gui.zip"

$gitUrl = "https://github.com/efranken/CS-Surf-ML"
$projectName = "CS-Surf-ML"

$mapSourcePath = "$mlDirectory\CS-Surf-ML\etc\aa_surf_time_test.bsp"
$mapDestinationPath = "$steamcmdInstallPath\cstrike\maps\aa_surf_time_test.bsp"

$gitPath = Join-Path $mlDirectory $projectName