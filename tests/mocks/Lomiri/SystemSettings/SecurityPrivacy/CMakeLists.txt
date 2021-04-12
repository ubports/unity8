set(MOCK_SECURITYPRIVACY_SOURCES
    plugin.cpp
    MockSecurityPrivacy.cpp
)

add_library(MockSecurityPrivacy MODULE ${MOCK_SECURITYPRIVACY_SOURCES})

target_link_libraries(MockSecurityPrivacy Qt5::Qml Qt5::Quick Qt5::Core)

add_unity8_mock(Lomiri.SystemSettings.SecurityPrivacy 1.0 Lomiri/SystemSettings/SecurityPrivacy TARGETS MockSecurityPrivacy)
