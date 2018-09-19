set(FakeUbuntuTelephonyQml_SOURCES
    plugin.cpp
    ContactWatcherData.cpp
    MockCallEntry.cpp
    MockCallManager.cpp
    MockContactWatcher.cpp
    MockTelepathyHelper.cpp
)

add_library(FakeUbuntuTelephonyQml MODULE ${FakeUbuntuTelephonyQml_SOURCES})

target_link_libraries(FakeUbuntuTelephonyQml Qt5::Core Qt5::Quick)

add_unity8_mock(Ubuntu.Telephony 0.1 Ubuntu/Telephony TARGETS FakeUbuntuTelephonyQml)
