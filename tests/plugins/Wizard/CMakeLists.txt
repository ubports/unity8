include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Wizard
)

add_executable(tst-wizard-pagelist
    tst_pagelist.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/PageList.cpp
)
qt5_use_modules(tst-wizard-pagelist Core Qml Test)
add_test(NAME wizardpagelisttest COMMAND env UNITY_TEST_ENV=1 ${CMAKE_CURRENT_BINARY_DIR}/tst-wizard-pagelist)

add_executable(tst-wizard-system
    tst_system.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/System.cpp
)
qt5_use_modules(tst-wizard-system Core DBus Qml Test)
add_test(NAME wizardsystemtest COMMAND ${CMAKE_CURRENT_BINARY_DIR}/tst-wizard-system)
