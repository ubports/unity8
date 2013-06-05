#
# Test that all source files contain a copyright header.
#

add_test(copyright ${CMAKE_CURRENT_SOURCE_DIR}/check_copyright.sh
    ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
