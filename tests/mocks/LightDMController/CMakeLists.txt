add_library(LightDMController MODULE
    plugin.cpp
    )

target_include_directories(LightDMController PUBLIC
    ${CMAKE_SOURCE_DIR}/tests/mocks/liblightdm/
    )

target_link_libraries(LightDMController
    MockLightDM
    )

qt5_use_modules(LightDMController Qml)

add_unity8_mock(LightDMController 0.1 LightDMController TARGETS LightDMController)
