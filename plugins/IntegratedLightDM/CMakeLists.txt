pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)
# TODO: Once we split out a separate greeter process, uncomment these lines
#pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-2)

add_subdirectory(liblightdm)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/IntegratedLightDM
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

add_library(IntegratedLightDM-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(IntegratedLightDM-qml
    integratedLightDM
    unity8-private
# TODO: Once we split out a separate greeter process, uncomment these lines
#    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(IntegratedLightDM-qml DBus Gui Qml)

add_unity8_plugin(IntegratedLightDM 0.1 IntegratedLightDM TARGETS IntegratedLightDM-qml)
