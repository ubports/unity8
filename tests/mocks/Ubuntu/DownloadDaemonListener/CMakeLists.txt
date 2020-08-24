set(FakeUbuntuDownloadDaemonListenerQml_SOURCES
    plugin.cpp
    MockDownloadTracker.cpp
)

add_library(FakeUbuntuDownloadDaemonListenerQml MODULE ${FakeUbuntuDownloadDaemonListenerQml_SOURCES})

target_link_libraries(FakeUbuntuDownloadDaemonListenerQml Qt5::Core Qt5::Quick)

add_unity8_mock(Ubuntu.DownloadDaemonListener 0.1 Ubuntu/DownloadDaemonListener TARGETS FakeUbuntuDownloadDaemonListenerQml)
