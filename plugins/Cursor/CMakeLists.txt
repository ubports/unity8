add_subdirectory(3rd_party)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/xcursor
)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    plugin.cpp
    CursorImageInfo.cpp
    CursorImageProvider.cpp
    MousePointer.cpp
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

qt5_use_modules(Cursor-qml Qml Quick Svg)

add_unity8_plugin(Cursor 1.1 Cursor TARGETS Cursor-qml)
