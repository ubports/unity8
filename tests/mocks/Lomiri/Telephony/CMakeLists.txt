set(FakeLomiriTelephonyQml_SOURCES
    plugin.cpp
    ContactWatcherData.cpp
    MockCallEntry.cpp
    MockCallManager.cpp
    MockContactWatcher.cpp
    MockTelepathyHelper.cpp
)

add_library(FakeLomiriTelephonyQml MODULE ${FakeLomiriTelephonyQml_SOURCES})

target_link_libraries(FakeLomiriTelephonyQml Qt5::Core Qt5::Quick)

add_lomiri_mock(Lomiri.Telephony 0.1 Lomiri/Telephony TARGETS FakeLomiriTelephonyQml)
