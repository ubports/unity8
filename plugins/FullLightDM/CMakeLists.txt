pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)
pkg_check_modules(LIBLIGHTDM_GOBJECT REQUIRED liblightdm-gobject-1)
pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-3)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${LIBLIGHTDM_INCLUDE_DIRS}
    ${libunity8-private_SOURCE_DIR}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    ../Utils/unitysortfilterproxymodelqml.cpp
    DBusGreeter.cpp
    DBusGreeterList.cpp
    Greeter.cpp
    plugin.cpp
    UsersModel.cpp
    )

add_library(FullLightDM-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(FullLightDM-qml
    unity8-private
    lightdm-qt5-3
    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(FullLightDM-qml DBus Gui Qml)

add_unity8_plugin(FullLightDM 0.1 FullLightDM TARGETS FullLightDM-qml)
