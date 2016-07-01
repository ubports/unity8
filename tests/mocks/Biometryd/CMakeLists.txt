set(MOCK_BIOMETRYD_SOURCES
    plugin.cpp
    MockBiometryd.cpp
    MockDevice.cpp
    MockIdentifier.cpp
    MockObserver.cpp
    MockOperation.cpp
)

add_library(MockBiometryd MODULE ${MOCK_BIOMETRYD_SOURCES})

qt5_use_modules(MockBiometryd Qml Quick Core)

add_unity8_mock(Biometryd 0.0 Biometryd TARGETS MockBiometryd)
