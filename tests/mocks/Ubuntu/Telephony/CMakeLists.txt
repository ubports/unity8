set(FakeUbuntuTelephonyQml_SOURCES
    plugin.cpp
    ContactWatcherData.cpp
    MockCallEntry.cpp
    MockCallManager.cpp
    MockContactWatcher.cpp
    MockTelepathyHelper.cpp
)

add_library(FakeUbuntuTelephonyQml MODULE ${FakeUbuntuTelephonyQml_SOURCES})

qt5_use_modules(FakeUbuntuTelephonyQml Core Quick)

add_unity8_mock(Ubuntu.Telephony 0.1 Ubuntu/Telephony TARGETS FakeUbuntuTelephonyQml)
