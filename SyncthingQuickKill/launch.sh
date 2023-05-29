#!/bin/sh
cd /mnt/SDCARD/App/Syncthing/
export sysdir=/mnt/SDCARD/.tmp_update
export miyoodir=/mnt/SDCARD/miyoo
export LD_LIBRARY_PATH="/mnt/SDCARD/App/Syncthing/lib:/lib:/config/lib:$miyoodir/lib:$sysdir/lib:$sysdir/lib/parasyte"
export PATH="$sysdir/bin:$PATH"
export TP=/mnt/SDCARD/App/Syncthing/bin/texpop

cleanup

splashclean() {
	bin/splash icon/splash.png 255 255 255 &
	splash_pid=$!
	kill -2 $splash_pid
}

refreshscreen() {
	killall -15 texpop
	sleep 1
	splashclean 
}

cleanup() {
	killall -15 texpop
	killall -15 splash
	exit
}

syncthingpid() {
	pgrep "syncthing" > /dev/null
}

if syncthingpid; then
	killall -9 syncthing
	splashclean
	$TP 1 "Syncthing killed" 0882C8 30 -1 25 
	cleanup
fi




