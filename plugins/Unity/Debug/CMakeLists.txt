include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${GIO_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    consolelog.cpp
    plugin.cpp
    )

add_library(Debug-qml SHARED
    ${QMLPLUGIN_SRC}
    )

# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(Debug-qml PROPERTIES COMPILE_FLAGS -fvisibility=default)

qt5_use_modules(Debug-qml Qml Quick Concurrent)

add_unity8_plugin(Unity.Debug 0.1 Unity/Debug TARGETS Debug-qml)
