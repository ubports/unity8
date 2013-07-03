# Dependencies
include(FindPkgConfig)
pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)
# TODO: Once we split out a separate greeter process, uncomment these lines
#pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-2)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    #${LIBLIGHTDM_INCLUDE_DIRS}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
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
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(LightDM-qml Gui Qml)

file(GLOB LightDM_QMLFILES
    qmldir
)

# copy qmldir file into build directory for shadow builds
add_custom_target(LightDMQmlFiles ALL
    COMMAND cp ${LightDM_QMLFILES} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${LightDM_QMLFILES}
)

# create the LightDM.qmltypes file
add_custom_target(LightDM-qmltyes ALL
    COMMAND qmlplugindump -notrelocatable LightDM 0.1 ${CMAKE_BINARY_DIR}/plugins > ${CMAKE_CURRENT_BINARY_DIR}/LightDM.qmltypes
)
add_dependencies(LightDM-qmltyes LightDM-qml LightDMQmlFiles)

install(TARGETS LightDM-qml
    DESTINATION ${SHELL_APP_DIR}/plugins/LightDM
    )

install(FILES ${LightDM_QMLFILES}
    DESTINATION ${SHELL_APP_DIR}/plugins/LightDM
    )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/LightDM.qmltypes
    DESTINATION ${SHELL_APP_DIR}/plugins/LightDM
    )
