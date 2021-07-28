pkg_check_modules(ANDROID_HEADERS REQUIRED android-headers)
pkg_check_modules(ANDROID_HARDWARE REQUIRED libhardware)

include_directories(
    SYSTEM
    ${ANDROID_HEADERS_INCLUDE_DIRS}
)

add_library(Lights-qml MODULE
    plugin.cpp
    Lights.cpp
    )

target_link_libraries(Lights-qml
    Qt5::Qml Qt5::Gui
    ${ANDROID_HARDWARE_LIBRARIES}
    )

add_lomiri_plugin(Lights 0.1 Lights TARGETS Lights-qml)
