add_custom_target(autopilot)

function(declare_autopilot_test TEST_NAME WORKING_DIR)
  add_custom_command(TARGET autopilot
  COMMAND autopilot run ${TEST_NAME}
  WORKING_DIRECTORY ${WORKING_DIR})
endfunction()
