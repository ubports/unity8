include_directories(
    ${GLIB_INCLUDE_DIRS}
)

set(SYSTEMIMAGE_SOURCES
    plugin.cpp
    SystemImage.cpp
)

add_library(SystemImage MODULE ${SYSTEMIMAGE_SOURCES})

qt5_use_modules(SystemImage Qml DBus Core)
target_link_libraries(SystemImage ${GLIB_LIBRARIES})

add_unity8_plugin(Ubuntu.SystemImage 0.1 Ubuntu/SystemImage TARGETS SystemImage)
