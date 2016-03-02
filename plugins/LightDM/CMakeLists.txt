pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)
pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-3)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_BINARY_DIR}/tests/mocks/LightDM/IntegratedLightDM
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
    SessionsModel.cpp
    UsersModel.cpp
    )

add_subdirectory(FullLightDM)
add_subdirectory(IntegratedLightDM)
