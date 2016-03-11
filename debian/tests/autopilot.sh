#!/bin/sh

# log all commands and abort on error
set -xe

if [ ! -f /system/build.prop ]; then
    echo "WARNING: Skipping autopilot test, will only run on devices at the moment."
    exit 0
fi

initctl --session stop unity8
autopilot3 run --verbose --format xml --output "${ADT_ARTIFACTS}/unity8.xml" unity8
initctl --session start unity8
