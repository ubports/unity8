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

qt5_use_modules(MockNotificationsPlugin Core Quick)

add_unity8_mock(Unity.Notifications 1.0 Unity/Notifications TARGETS MockNotificationsPlugin)
