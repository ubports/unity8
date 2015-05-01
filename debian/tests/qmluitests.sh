#!/bin/sh

SHELL_QML_PATH=$(pkg-config --variable=plugindir unity-shell-api)

dh_auto_configure -- -DCMAKE_INSTALL_LOCALSTATEDIR="/var" \
                     -DARTIFACTS_DIR=${ADT_ARTIFACTS} \
                     -DUNITY_PLUGINPATH=${SHELL_QML_PATH} \
                     -DUNITY_MOCKPATH=${SHELL_QML_PATH}/mocks \
                     -DQUIET_LOGGER=ON
dh_auto_build --parallel -- -C tests/mocks 2>&1
dh_auto_build --parallel -- -C tests/plugins 2>&1
dh_auto_build --parallel -- -C tests/qmltests 2>&1
dh_auto_build --parallel -- -C tests/uqmlscene 2>&1
dh_auto_build --parallel -- -C tests/utils 2>&1

# FIXME: --parallel here causes some failures
dh_auto_build -- -k test xvfbuitests
