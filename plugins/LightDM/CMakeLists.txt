pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${libunity8-private_SOURCE_DIR}
    )

include_directories(
    SYSTEM
    ${LIBLIGHTDM_INCLUDE_DIRS}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
    )

add_library(LightDM-qml MODULE
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    DBusGreeter.cpp
    DBusGreeterList.cpp
    Greeter.cpp
    plugin.cpp
    SessionsModel.cpp
    UsersModel.cpp
    )

target_link_libraries(LightDM-qml
    unity8-private
    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(LightDM-qml DBus Gui Qml)
add_unity8_plugin(LightDM 0.1 LightDM TARGETS LightDM-qml)
