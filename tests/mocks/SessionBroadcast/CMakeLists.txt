add_library(MockSessionBroadcast-qml MODULE
    plugin.cpp
    SessionBroadcast.cpp
    )

target_link_libraries(MockSessionBroadcast-qml Qt5::Qml)

add_lomiri_mock(SessionBroadcast 0.1 SessionBroadcast TARGETS MockSessionBroadcast-qml)
