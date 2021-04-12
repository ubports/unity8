#!/bin/sh

# log all commands and abort on error
set -xe

if [ ! -f /system/build.prop ]; then
    echo "WARNING: Skipping autopilot test, will only run on devices at the moment."
    exit 0
fi

initctl --session stop lomiri
autopilot3 run --verbose --format xml --output "${ADT_ARTIFACTS}/lomiri.xml" lomiri
initctl --session start lomiri
