set(FakeLomiriDownloadDaemonListenerQml_SOURCES
    plugin.cpp
    MockDownloadTracker.cpp
)

add_library(FakeLomiriDownloadDaemonListenerQml MODULE ${FakeLomiriDownloadDaemonListenerQml_SOURCES})

target_link_libraries(FakeLomiriDownloadDaemonListenerQml Qt5::Core Qt5::Quick)

add_lomiri_mock(Lomiri.DownloadDaemonListener 0.1 Lomiri/DownloadDaemonListener TARGETS FakeLomiriDownloadDaemonListenerQml)
