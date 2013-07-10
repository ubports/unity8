add_custom_target(autopilot)

function(declare_autopilot_test TEST_NAME WORKING_DIR)
    add_custom_target(autopilot-${TEST_NAME}
        COMMAND autopilot run ${TEST_NAME}
        WORKING_DIRECTORY ${WORKING_DIR}
    )

    add_dependencies(autopilot autopilot-${TEST_NAME})
endfunction()
