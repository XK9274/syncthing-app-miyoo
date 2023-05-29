# syncthing-app-miyoo
Sets up Syncthing and injects into Onion 4.2.0 beta 3 runtime.sh
![syncthing](https://github.com/XK9274/syncthing-app-miyoo/assets/47260768/c705ce9c-ad1e-4e66-ac43-9ea16c82cf26)
![Syncthing_001](https://github.com/XK9274/syncthing-app-miyoo/assets/47260768/600624d1-fe60-4cfb-8d2a-3cefd71627a7)
![2](https://github.com/XK9274/syncthing-app-miyoo/assets/47260768/65448a0f-4aaf-44be-abbc-01cb7651042a)


## Issues 
- Will run as root as we can't add/remove users.
- On OnionOS 4.2.0 dev3 you may have issues where Main hangs after the app quits, press x or y then back and you should be unlocked again.
- Device name will be (none) as the hostname never gets set. You can set this by changing the first line containing (none) in the config.xml file in the Syncthing App folder (and then restart) 
- It uses the hostname when generating config for the device name, which can be checked with `uname -n` and set with `hostname MYHOSTNAME` but changing the config.xml is best.
- The installer is slow as it redraws a splash and text, any quicker and redraws over the top of itself.. i'll maybe remake it in C.
- After the first run you can delete the main app and just keep QuickKill

## Usage
After the first run you shouldn't have to run the app again unless you want to kill syncthing (for that session)

- Download the Syncthing folder and add to your Apps folder on the SDCARD (/Apps/Syncthing)

- Run the app, the first time it will:
	- inject a line into the runtime.sh 
	- generate the config
	- start the syncthing process
	
- Run the app, the second time will:
	- shut down the process for this session (starts again on reload)
	
Syncthing will now start up on boot (main launch) and be accessible by your IP address on wifi (!Not your hotspot address..!)

If you wish to remove syncthing from running at boot, open /.tmp_update/runtime.sh and remove line 99:
`/mnt/SDCARD/App/Syncthing/bin/syncthing --home=/mnt/SDCARD/App/Syncthing/config/ > /mnt/SDCARD/App/Syncthing/logfile.log 2>&1 & #SYNCTHING INJECTOR`
	
## Source
- https://github.com/syncthing/syncthing
- https://github.com/XK9274/texpop-miyoo
- https://github.com/XK9274/splash-miyoo
