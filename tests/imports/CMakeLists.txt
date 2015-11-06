
#
# Test that all imports for QtQuick and Ubuntu.Components use the wanted version
#
add_test(imports ${CMAKE_CURRENT_SOURCE_DIR}/check_imports.py ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
