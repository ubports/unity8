include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Wizard
)

add_executable(tst-pagelist
    tst_pagelist.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/PageList.cpp
)
qt5_use_modules(tst-pagelist Core Qml Test)

add_test(NAME pagelisttest COMMAND env UNITY_TEST_ENV=1 ${CMAKE_CURRENT_BINARY_DIR}/tst-pagelist)
