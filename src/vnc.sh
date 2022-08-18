#!/bin/bash

vnc="/usr/bin/x11vnc -display ${DISPLAY} -forever -shared -ncache 10"

pass_path="/root/vncpass"
if [ ! -z "${VNC_PASSWORD}" ]; then
	/usr/bin/x11vnc -storepasswd ${VNC_PASSWORD} ${pass_path}
	param="-rfbauth ${pass_path}"
else 
	param="-nopw"
fi

${vnc}${param}
