# Dependencies
# TODO: Once we split out a separate greeter process, uncomment these lines
#include(FindPkgConfig)
#pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-2)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    #${LIBLIGHTDM_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    ../Utils/qsortfilterproxymodelqml.cpp # FIXME evaluate a more generic approach for using other plugins
    Greeter.cpp
    plugin.cpp
    UsersModel.cpp
    )

add_library(LightDM-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(LightDM-qml
    MockLightDM-demo
# TODO: Once we split out a separate greeter process, uncomment these lines
#    ${LIBLIGHTDM_LDFLAGS}
    )

qt5_use_modules(LightDM-qml Gui Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS LightDM-qml
    DESTINATION ${SHELL_APP_DIR}/plugins/LightDM
    )

install(FILES qmldir
    DESTINATION ${SHELL_APP_DIR}/plugins/LightDM
    )