pkg_check_modules(ANDROID_HEADERS REQUIRED android-headers)
pkg_check_modules(ANDROID_HARDWARE REQUIRED libhardware)
pkg_check_modules(ANDROID_PROPERTIES REQUIRED libandroid-properties)

include_directories(
    SYSTEM
    ${ANDROID_HEADERS_INCLUDE_DIRS}
)

add_library(Lights-qml MODULE
    plugin.cpp
    Lights.cpp
    LegacyLights.cpp
    HfdLights.cpp
    )

target_link_libraries(Lights-qml
    Qt5::Qml Qt5::Gui Qt5::DBus
    ${ANDROID_HARDWARE_LIBRARIES}
    ${ANDROID_PROPERTIES_LIBRARIES}
    )

add_unity8_plugin(Lights 0.1 Lights TARGETS Lights-qml)
