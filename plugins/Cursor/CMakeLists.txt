add_subdirectory(3rd_party)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/xcursor
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    plugin.cpp
    MousePointer.cpp
    CursorImageProvider.cpp
    # We need to run moc on this header
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirMousePointerInterface.h
    )

add_library(Cursor-qml SHARED
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(Cursor-qml
    xcursorloader-static
    ${QT5PLATFORM_SUPPORT_LDFLAGS}
)

qt5_use_modules(Cursor-qml Qml Quick DBus Network Gui Sql Concurrent Svg)

add_unity8_plugin(Cursor 1.0 Cursor TARGETS Cursor-qml)
