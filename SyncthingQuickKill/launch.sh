#!/bin/sh

syncthingpid() {
	pgrep "syncthing" > /dev/null
}

if syncthingpid; then
	killall -9 syncthing
fi




