# Dependencies
include(FindPkgConfig)
pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)
# TODO: Once we split out a separate greeter process, uncomment these lines
#pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-2)

add_subdirectory(liblightdm)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    #${LIBLIGHTDM_INCLUDE_DIRS}
    ${libunity8-private_SOURCE_DIR}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    ../Utils/unitysortfilterproxymodelqml.cpp # FIXME evaluate a more generic approach for using other plugins
    DBusGreeter.cpp
    DBusGreeterList.cpp
    Greeter.cpp
    plugin.cpp
    UsersModel.cpp
    )

add_library(LightDM-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(LightDM-qml
    integratedLightDM
    unity8-private
# TODO: Once we split out a separate greeter process, uncomment these lines
#    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(LightDM-qml DBus Gui Qml)

add_unity8_plugin(LightDM 0.1 LightDM TARGETS LightDM-qml)
