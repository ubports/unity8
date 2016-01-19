set(MOCK_SECURITYPRIVACY_SOURCES
    plugin.cpp
    MockSecurityPrivacy.cpp
)

add_library(MockSecurityPrivacy MODULE ${MOCK_SECURITYPRIVACY_SOURCES})

qt5_use_modules(MockSecurityPrivacy Qml Quick Core)

add_unity8_mock(Ubuntu.SystemSettings.SecurityPrivacy 1.0 Ubuntu/SystemSettings/SecurityPrivacy PREFIX mocks TARGETS MockSecurityPrivacy)
