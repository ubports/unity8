include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Wizard
)

add_executable(tst-wizard-pagelist
    tst_pagelist.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/PageList.cpp
)
target_link_libraries(tst-wizard-pagelist Qt5::Core Qt5::Qml Qt5::Test)
install(TARGETS tst-wizard-pagelist
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Wizard"
)
add_lomiri_unittest(WizardPageList tst-wizard-pagelist ENVIRONMENT WIZARD_TESTING=1)

add_executable(tst-wizard-system
    tst_system.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/System.cpp
)
target_link_libraries(tst-wizard-system Qt5::Core Qt5::DBus Qt5::Qml Qt5::Test)
install(TARGETS tst-wizard-system
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Wizard"
)
add_lomiri_unittest(WizardSystem tst-wizard-system)
