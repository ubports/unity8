include_directories(
    SYSTEM
    ${ANDROID_HEADERS_INCLUDE_DIRS}
)

add_library(Lights-qml MODULE
    plugin.cpp
    Lights.cpp
    )

qt5_use_modules(Lights-qml DBus Qml Gui)
target_link_libraries(Lights-qml)

add_unity8_plugin(Lights 0.1 Lights TARGETS Lights-qml)
