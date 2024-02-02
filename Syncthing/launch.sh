#!/bin/sh
cd $appdir/
sysdir=/mnt/SDCARD/.tmp_update
miyoodir=/mnt/SDCARD/miyoo
LD_LIBRARY_PATH="$appdir/lib:/lib:/config/lib:$miyoodir/lib:$sysdir/lib:$sysdir/lib/parasyte"
PATH="$sysdir/bin:$PATH"
appdir=/mnt/SDCARD/App/Syncthing
skiplast=0

check_injector() {
    if grep -q "#SYNCTHING INJECTOR" "$sysdir/runtime.sh"; then
        return 0
    else
        return 1
    fi
}

build_infoPanel() {
    local message="$1"
	local title="Syncthing Installer"
	
	infoPanel --title "$title" --message "$message" --persistent &
	touch /tmp/dismiss_info_panel
	sync
	sleep 1
}

syncthingpid() {
	pgrep "syncthing" > /dev/null
}

injectruntime() {
    build_infoPanel "Injecting config into runtime.sh..."
    sed -i '/# Auto launch/i \\	sh /mnt/SDCARD/App/Syncthing/script/checkrun.sh #SYNCTHING INJECTOR #SYNCTHING INJECTOR' $sysdir/runtime.sh
    touch $appdir/config/gotime
    if grep -q "#SYNCTHING INJECTOR" "$sysdir/runtime.sh"; then
        build_infoPanel "Injection successful..."
    else
        build_infoPanel "Injection failed..."
    fi
}

repair_config() {
    local config="$appdir/config/config.xml"

    if grep -q "<listenAddress>dynamic+https://relays.syncthing.net/endpoint</listenAddress>" "$config"; then
        build_infoPanel "Config not generated correctly, \n Manually repairing"
        
        sed -i '/<listenAddress>dynamic+https:\/\/relays.syncthing.net\/endpoint<\/listenAddress>/d' "$config"
        sed -i '/<listenAddress>quic:\/\/0.0.0.0:41383<\/listenAddress>/d' "$config"
        
        sed -i 's|<listenAddress>tcp://0.0.0.0:41383</listenAddress>|<listenAddress>default</listenAddress>|' "$config"
        sed -i 's|<address>127.0.0.1:40379</address>|<address>0.0.0.0:8384</address>|' "$config"
        
        if grep -q "<address>0.0.0.0:8384</address>" "$config" && grep -q "<listenAddress>default</listenAddress>" "$config"; then
            build_infoPanel "Repair complete. \n GUI IP Forced to 0.0.0.0"
        else
            build_infoPanel "Failed to repair config \n Remove the app dir \n and try again"
        fi
    fi
}

startsyncthing() {
	if syncthingpid; then
		build_infoPanel "Already running..."
	else
		build_infoPanel "Starting Syncthing..."
		$appdir/bin/syncthing serve --home=$appdir/config/ > $appdir/serve.log 2>&1 &
	fi
}

firststart() {
    if [ ! -f $appdir/config/config.xml ]; then
        build_infoPanel "Config file not found, generating..."
        $appdir/bin/syncthing generate --no-default-folder --home=$appdir/config/ > $appdir/generate.log 2>&1 &
        sleep 5
        
        repair_config # check if the config was generated correctly
        
        pkill syncthing
    fi
}

changeguiip() {
	sync
    IP=$(ip route get 1 | awk '{print $NF;exit}')
    
    if grep -q "<address>0.0.0.0:8384</address>" $appdir/config/config.xml; then
        build_infoPanel "IP already setup in config"
        sleep 1
        build_infoPanel "GUI IP is $IP:8384"
        skiplast=1
        sleep 5
    fi

    build_infoPanel "Setting IP" "Changing GUI IP:Port to $IP:8384"
    sed -i "s|<address>127.0.0.1:8384</address>|<address>0.0.0.0:8384</address>|g" $appdir/config/config.xml

    if [[ $? -eq 0 && $(grep -c "<address>0.0.0.0:8384</address>" $appdir/config/config.xml) -gt 0 ]]; then
        build_infoPanel "GUI IP set to $IP:8384"
        sleep 5
    else
        build_infoPanel "Failed to set IP address"
    fi
}

########################## GO TIME

########################## GO TIME

########################## GO TIME


build_infoPanel "Syncthing setup"

build_infoPanel "Checking if we're already configured..."

if check_injector; then
    build_infoPanel "We're already configured.."

    if syncthingpid; then
        build_infoPanel "Running. killing until next reboot"
        killall -9 syncthing
        build_infoPanel "Finished" "Done..."
    else
        startsyncthing
    fi
else
    build_infoPanel "We're not configured, starting"    
    firststart
    injectruntime
    changeguiip
    startsyncthing
    if [ "$skiplast" -ne 1 ]; then
        build_infoPanel "Browse to $IP:8384 to setup!"
    fi      
fi
