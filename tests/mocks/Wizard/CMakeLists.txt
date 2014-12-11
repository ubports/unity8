include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Wizard
)

add_library(MockWizard-qml MODULE
    mockplugin.cpp
    MockSystem.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/PageList.cpp
)

qt5_use_modules(MockWizard-qml Qml)
add_unity8_mock(Wizard 0.1 Wizard TARGETS MockWizard-qml)
