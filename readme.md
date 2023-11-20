Required software:

- MySQL Community edition
- MetaMod and SourceMod
- Counter-Strike: Source
- SteamCMD
- SteamCMD-GUI
- Python3

# Full install instructions

Download the repo and place in a folder that will be used as the working directory for the install process.

## SteamCMD Dedicated Server
1.  Make a folder named SteamCMD in the working directory
2.  Download [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD#Downloading_SteamCMD) to SteamCMD folder
3.  Make a folder for the game install in working directory
4.  Run the .exe, wait for updates to download
5.  Make a folder named `CSS` for app install in SteamCMD folder
6.  Enter the following commands:
   
    `force_install_dir $WORKDIR\SteamCMD\CSS` WHERE $WORKDIR IS THE FULL PATH OF WORKING DIRECTORY (ex h:\cssml)

    `login anonymous` to login to Steam public without an account
    
    `app_update 232330 validate` to install CS:S dedicated server
7.  Copy and paste aa_surf_time_test.bsp from \etc\ to $WORKDIR\SteamCMD\CSS\cstrike\maps
8.  Make a folder at $WORKDIR called SteamCMD-GUI
9.  Install [SteamCMD-GUI](https://github.com/DioJoestar/SteamCMD-GUI/releases/latest) to the folder just created
10. Run SteamCMD GUI.exe and set the following parameters in the Run Server tab:
    - Srcds path set to `$WORKDIR\SteamCMD\CSS`
    - Game Configuration set to `Counter-Strike: Source`
    - Map set to aa_surf_time_test

  @TODO make a config for server that is good for surf (airaccell 100 etc)

11.  Click run to run server
12.  Open CS:S and test by browsing to LAN tab and connecting to server


## SourceMod and MetaMod configuration

1.  Download and install [Metamod](https://www.sourcemm.net/) and [SourceMod](https://www.sourcemod.net/)
2.  

## Database configuration

1.  Download and install MySQL Community Edition
    a. Install as developer default role
    b. Set root password on install, make note of it
2.  Launch MySQL Workbench
3.  Connect to your local server instance
4.  Create a new Schema named `ml` in MySQL
5.  Send the following query to it to build the database structure

    ```
    CREATE TABLE IF NOT EXISTS playerloc (
        id			TINYINT  UNSIGNED NOT NULL,
        x			SMALLINT				NOT NULL,
        y			SMALLINT				NOT NULL,
        z			SMALLINT				NOT NULL,
        angle		SMALLINT				NOT NULL,
        speed		SMALLINT   UNSIGNED	NOT NULL,
        ticknum	INT      UNSIGNED	NOT NULL,
        writenum	INT		UNSIGNED	NOT NULL,
        episode	INT		UNSIGNED	NOT NULL,
        INDEX (id),
        INDEX (writenum)	
    ) ENGINE=MyISAM
    ```
6. Create a user under server/users and priveleges
7. Set the password to Standard, the default may be caching_sha2_password
8. Give the user rights to the `ml` schema under the "Schema Priveleges" tab
9. Add the following to your `/addons/sourcemod/configs/databases.cfg`

    ```
        "ml"
        {
            "driver" "mysql"
            "host" "localhost"
            "database" "ml"
            "user" "ml" CHANGE THIS LINE TO YOUR USER
            "pass" "ml" CHANGE THIS LINE TO YOUR PW
        }
    ```
