include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Wizard
)

add_executable(tst-wizard-pagelist
    tst_pagelist.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/PageList.cpp
)
qt5_use_modules(tst-wizard-pagelist Core Qml Test)
install(TARGETS tst-wizard-pagelist
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Wizard"
)
add_unity8_unittest(WizardPageList tst-wizard-pagelist ENVIRONMENT WIZARD_TESTING=1)

add_executable(tst-wizard-system
    tst_system.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/System.cpp
)
qt5_use_modules(tst-wizard-system Core DBus Qml Test)
install(TARGETS tst-wizard-system
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Wizard"
)
add_unity8_unittest(WizardSystem tst-wizard-system)
