set(FakeUbuntuDownloadDaemonListenerQml_SOURCES
    plugin.cpp
    MockDownloadTracker.cpp
)

add_library(FakeUbuntuDownloadDaemonListenerQml MODULE ${FakeUbuntuDownloadDaemonListenerQml_SOURCES})

qt5_use_modules(FakeUbuntuDownloadDaemonListenerQml Core Quick)

add_unity8_mock(Ubuntu.DownloadDaemonListener 0.1 Ubuntu/DownloadDaemonListener TARGETS FakeUbuntuDownloadDaemonListenerQml)
