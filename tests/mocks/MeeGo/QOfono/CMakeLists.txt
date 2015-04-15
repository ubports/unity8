set(MOCK_QOFONO_SOURCES
    plugin.cpp
    MockQOfono.cpp
    MockQOfonoManager.cpp
)

add_library(MockQOfono MODULE ${MOCK_QOFONO_SOURCES})

qt5_use_modules(MockQOfono Qml Quick Core)

add_unity8_mock(MeeGo.QOfono 0.2 MeeGo/QOfono TARGETS MockQOfono)
