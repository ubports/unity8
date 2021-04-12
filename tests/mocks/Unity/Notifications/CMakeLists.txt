include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(MockNotificationsPlugin_SOURCES
    plugin.cpp
    MockNotification.cpp
    MockNotificationModel.cpp
    MockActionModel.cpp
)

add_library(MockNotificationsPlugin MODULE ${MockNotificationsPlugin_SOURCES})

target_link_libraries(MockNotificationsPlugin Qt5::Core Qt5::Quick)

add_lomiri_mock(Unity.Notifications 1.0 Unity/Notifications TARGETS MockNotificationsPlugin)
