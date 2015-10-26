
#
# Test that all imports for Ubuntu.Components use the wanted version
#

add_test(SDK ${CMAKE_CURRENT_SOURCE_DIR}/check_sdk.py ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
