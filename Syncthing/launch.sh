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

checkstatus() {
	refreshscreen
	$TP 1 "Checking if Syncthing is running..." 0882C8 30 -1 25 
	refreshscreen
}

injectruntime() {
    $TP 1 "Injecting config into runtime.sh..." 0882C8 30 -1 25 
    refreshscreen 
    sed -i '/# Main runtime loop/i \\	sh /mnt/SDCARD/App/Syncthing/script/checkrun.sh #SYNCTHING INJECTOR' $sysdir/runtime.sh
    touch /mnt/SDCARD/App/Syncthing/config/gotime
    if grep -q "#SYNCTHING INJECTOR" "$sysdir/runtime.sh"; then
        $TP 1 "Injection successful..." 0882C8 30 -1 25 
    else
        $TP 1 "Injection failed..." 0882C8 30 -1 25 
    fi
    refreshscreen 
}

startsyncthing() {
	if syncthingpid; then
		return
	else
		$TP 1 "Starting Syncthing..." 0882C8 30 -1 25 
		refreshscreenn 
		/mnt/SDCARD/App/Syncthing/bin/syncthing serve --home=/mnt/SDCARD/App/Syncthing/config/ > /mnt/SDCARD/App/Syncthing/serve.log 2>&1 &
	fi
	refreshscreen
	sleep 0.5
}

firststart() {
	if [ ! -f /mnt/SDCARD/App/Syncthing/config/config.xml ]; then
		$TP 1 "Config file not found, generating..." 0882C8 30 -1 25 
		/mnt/SDCARD/App/Syncthing/bin/syncthing generate --no-default-folder --home=/mnt/SDCARD/App/Syncthing/config/ > /mnt/SDCARD/App/Syncthing/generate.log 2>&1 &
		sleep 5
		refreshscreen
		pkill syncthing
	fi
}

changeguiip() {
	sync
    IP=$(ip route get 1 | awk '{print $NF;exit}')
    $TP 1 "Changing GUI IP:Port to $IP:8384" 0882C8 30 -1 25 
    sed -i "s|<address>127.0.0.1:8384</address>|<address>$IP:8384</address>|g" /mnt/SDCARD/App/Syncthing/config/config.xml
	refreshscreen
    if [[ $? -eq 0 && $(grep -c "<address>$IP:8384</address>" /mnt/SDCARD/App/Syncthing/config/config.xml) -gt 0 ]]; then
        $TP 1 "GUI IP set to $IP:8384" 0882C8 30 -1 25 
		refreshscreen
    else
        $TP 1 "Failed to set IP address" 0882C8 30 -1 25 
		refreshscreen
    fi
    refreshscreen
}

finished() {
	$TP 1 "Done..." 0882C8 30 -1 25 
	refreshscreen
}

########################## GO TIME

########################## GO TIME

########################## GO TIME

splashclean 
refreshscreen

$TP 1 "Syncthing installer" 0882C8 30 -1 25 
refreshscreen

$TP 1 "Checking if we're already configured..." 0882C8 30 -1 25 
refreshscreen

if [ -f "/mnt/SDCARD/App/Syncthing/config/gotime" ]; then
	refreshscreen
    $TP 1 "We're already configured.." 0882C8 30 -1 25 
	sleep 0.5
	checkstatus
	if syncthingpid; then 
		refreshscreen
		$TP 1 "Running. killing until next reboot" 0882C8 30 -1 25 
		refreshscreen
		killall -9 syncthing
		sleep 0.5
		finished
		sleep 0.5
		cleanup
	else
		refreshscreen
		sleep 0.5
		startsyncthing
	fi
else
	refreshscreen
    $TP 1 "We're not configured, starting" 0882C8 30 -1 25 
	sleep 0.5
	refreshscreen
	sleep 0.5
	firststart
	sleep 0.5
	injectruntime
	sleep 0.5
	changeguiip
	sleep 0.5
	startsyncthing
	sleep 0.5
	refreshscreen
	$TP 1 "Browse to $IP:8384 to setup!" 0882C8 30 -1 25 
fi


cleanup
cleanup




