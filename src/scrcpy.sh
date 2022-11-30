#!/bin/bash

if [ -z "$REAL_DEVICE"]; then
  echo "Container is using android emulator"
  sleep 1
else
  echo "Starting android screen copy..."
  /usr/bin/scrcpy
fi
