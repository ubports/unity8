add_custom_target(autopilot)

function(declare_autopilot_test TEST_NAME TEST_SUITE WORKING_DIR)
    add_custom_target(autopilot-${TEST_NAME}
        COMMAND LANG=C UBUNTU_ICON_THEME=ubuntu-mobile QML2_IMPORT_PATH=${SHELL_INSTALL_QML}/mocks autopilot run ${TEST_SUITE}
        WORKING_DIRECTORY ${WORKING_DIR}
        DEPENDS install
    )

    add_dependencies(autopilot autopilot-${TEST_NAME})
endfunction()
