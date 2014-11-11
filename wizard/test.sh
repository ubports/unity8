#!/bin/sh

TOPDIR=$(readlink -e "$(dirname ${0})/..")

LOCAL_PRIVATE_DIR=$(ls -d ${TOPDIR}/debian/tmp/usr/lib/*/ubuntu-system-settings/private)
if [ -n ${LOCAL_PRIVATE_DIR} ]; then
    echo "Testing against locally built version"
    export UBUNTU_SYSTEM_SETTINGS_WIZARD_ROOT="${TOPDIR}/debian/tmp/usr/share"
    export UBUNTU_SYSTEM_SETTINGS_WIZARD_MODULES="${LOCAL_PRIVATE_DIR}"
    export QML2_IMPORT_PATH=${LOCAL_PRIVATE_DIR}:${QML2_IMPORT_PATH}
    export PATH=${TOPDIR}/debian/tmp/usr/bin:${PATH}
else
    echo "Testing against system version"
fi

export QML2_IMPORT_PATH=${TOPDIR}/tests/mocks:${QML2_IMPORT_PATH}

exec system-settings-wizard
