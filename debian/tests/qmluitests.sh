#!/bin/sh
# -*- Mode: sh; indent-tabs-mode: nil; tab-width: 4 -*-

# log all commands and abort on error
set -xe

DEB_HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)

export ARTIFACTS_DIR="${ADT_ARTIFACTS}"

/usr/lib/$DEB_HOST_MULTIARCH/unity8/tests/scripts/xvfballtests.sh
