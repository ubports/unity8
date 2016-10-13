add_library(MockSessionBroadcast-qml MODULE
    plugin.cpp
    SessionBroadcast.cpp
    )

qt5_use_modules(MockSessionBroadcast-qml Qml)

add_unity8_mock(SessionBroadcast 0.1 SessionBroadcast TARGETS MockSessionBroadcast-qml)
