# syncthing-app-miyoo

Sets up Syncthing and injects into Onion 4.2.0 beta runtime.sh
![Syncthing_001](https://github.com/XK9274/syncthing-app-miyoo/assets/47260768/600624d1-fe60-4cfb-8d2a-3cefd71627a7)
![syncthing](https://github.com/XK9274/syncthing-app-miyoo/assets/47260768/c705ce9c-ad1e-4e66-ac43-9ea16c82cf26)
![2](https://github.com/XK9274/syncthing-app-miyoo/assets/47260768/98dc6645-e280-43d1-9910-56b51ead859a)

## Issues

- Will run as root as we can't add/remove users.
- On OnionOS 4.2.0 dev3 you may have issues where Main hangs after the app quits, press x or y then back and you should be unlocked again.
- Device name will be (none) as the hostname never gets set. You can set this by changing the first line containing (none) in the config.xml file in the Syncthing App folder (and then restart)
- It uses the hostname when generating config for the device name, which can be checked with `uname -n` and set with `hostname MYHOSTNAME` but changing the config.xml is best.
- The installer is slow as it redraws a splash and text, any quicker and redraws over the top of itself.. I'll maybe remake it in C.

## Usage

After the first run you shouldn't have to run the app again unless you want to kill syncthing (for that session)

- Download the Syncthing folder and add to your Apps folder on the SDCARD (/App/Syncthing)
  _optional: Copy the SyncthingQuickKill folder to (/App/SyncthingQuickKill) if you want the ability to Quick Kill until restart. This folder/app is not necessary to use Syncthing_

- Run the app, the first time it will:

  - inject a line into the runtime.sh
  - generate the config
  - start the syncthing process

- Run the app, the second time will:
  - shut down the process for this session (starts again on reload)

Syncthing will now start up on boot (main launch). You can access the settings via a web browser on a computer/phone/tablet that is connected to the same network via the IP address and port number 8384 on wifi (!Not your hotspot address..!). Go to Settings and look to the right of "WIFI" for your device's IP address. Example address: 192.168.0.1:8384 (the colon : and 8384 is the port that Syncthing uses and is required).

If you wish to remove syncthing from running at boot, open /.tmp_update/runtime.sh and remove the line that contains:
`#SYNCTHING INJECTOR`

## Tips

- Set a password for access. Once you connect to the device via its IP:8384 in your browser click on "Actions" then "Settings" and under the "GUI" tab you will see fields for "GUI Authentication User" and "GUI Authentication Password". Don't forget the login info.
- Here is the [LINK](https://docs.syncthing.net/users/faq.html) to the official Syncthing FAQ that should be able to answer most every question you will have.
- If you're using filezilla to transfer files to the MMP you need to change the Transfer type to Binary in the Transfer menu at the top left otherwise binaries are broken on transfer and this will not run.

## Source

- https://github.com/syncthing/syncthing
- https://github.com/XK9274/texpop-miyoo
- https://github.com/XK9274/splash-miyoo
