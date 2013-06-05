#
# Test that all source files, cmakefiles, etc. do not contain trailing whitespace.
#

add_test(whitespace ${CMAKE_CURRENT_SOURCE_DIR}/check_whitespace.py ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
