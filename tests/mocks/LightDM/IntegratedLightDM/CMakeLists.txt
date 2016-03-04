# This is a copy of the normal LightDM plugin, but instead of statically
# linking in the lightdm bits, this one uses shared libraries so we can swap
# out different sets of users for different tests.  When we finally switch to
# actually using the system liblightdm in the normal plugin, this version can
# be deleted.

add_subdirectory(liblightdm)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/tests/mocks/libusermetrics
    ${libunity8-private_SOURCE_DIR}
)

set(QMLPLUGIN_SRC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/DBusGreeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/DBusGreeterList.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/SessionsModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    MockGreeter.cpp
    MockSessionsModel.cpp
    MockUsersModel.cpp
    plugin.cpp
    )

add_library(MockLightDM-qml MODULE
    ${QMLPLUGIN_SRC}
    )

# We want to link to liblightdm-qt5-3, but we don't want to depend on it being
# installed on the system.  So we make sure we link to our full fake version
# At run time, we can point to whichever version we happen to be using via
# LD_LIBRARY_PATH.
target_link_libraries(MockLightDM-qml
    MockLightDM
    MockUserMetrics
    unity8-private
    )

qt5_use_modules(MockLightDM-qml DBus Gui Qml)

add_unity8_mock(LightDM.IntegratedLightDM 0.1 LightDM/IntegratedLightDM
    PREFIX mocks
    TARGETS MockLightDM-qml
    ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}/liblightdm"
)
