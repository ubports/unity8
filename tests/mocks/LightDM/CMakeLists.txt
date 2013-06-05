# This is a copy of the normal LightDM plugin, but instead of statically
# linking in the lightdm bits, this one uses shared libraries so we can swap
# out different sets of users for different tests.  When we finally switch to
# actually using the system liblightdm in the normal plugin, this version can
# be deleted.

add_subdirectory(demo)
add_subdirectory(full)
add_subdirectory(single)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(QMLPLUGIN_SRC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/plugin.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qsortfilterproxymodelqml.cpp
    )

add_library(MockLightDM-qml MODULE
    ${QMLPLUGIN_SRC}
    )

# We want to link to liblightdm-qt5-2, but we don't want to depend on it being
# installed on the system.  So we make sure we link to our full fake version
# At run time, we can point to whichever version we happen to be using via
# LD_LIBRARY_PATH.
add_dependencies(MockLightDM-qml MockLightDM-full)
target_link_libraries(MockLightDM-qml
    -L${CMAKE_CURRENT_BINARY_DIR}/full
    -llightdm-qt5-2
    )

qt5_use_modules(MockLightDM-qml Gui Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS MockLightDM-qml
    DESTINATION ${SHELL_APP_DIR}/plugins/mocks/LightDM
    )

install(FILES qmldir
    DESTINATION ${SHELL_APP_DIR}/plugins/mocks/LightDM
    )
