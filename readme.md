Required software:

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
7.  Copy and paste aa_surf_time_test.bsp from \css-server\ to $WORKDIR\SteamCMD\CSS\cstrike\maps
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

## UDP Stream Configuration

By default, tickudp.smx broadcasts udp from 0.0.0.0 to 255.255.255.2555:27016.  These parameters can be changed by modifying tickudp.sp and recompiling.

## rolling todo

- 1.  move steamcmd_config to a couple different files
- 2.  make a main runner script
- 3.  configure database    script
download sourcemod/metamod

1.  start steam server properly
2.  connect to it from vm
3.  get virtual controller working via scripted install
4.  get the correct versions of openai stuff, or convert if needed
5.  get it running like i had in the youtube video