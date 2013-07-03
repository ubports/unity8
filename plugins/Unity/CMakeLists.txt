# Dependencies
include(FindPkgConfig)
pkg_check_modules(QTDEE REQUIRED libdee-qt5)
pkg_check_modules(UNITYCORE REQUIRED unity-core-6.0)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${QTDEE_INCLUDE_DIRS}
    ${UNITYCORE_INCLUDE_DIRS}
    ${Qt5DBus_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    ../Utils/qsortfilterproxymodelqml.cpp # FIXME evaluate a more generic approach for using other plugins
    scope.cpp
    scopes.cpp
    categories.cpp
    categoryfilter.cpp
    plugin.cpp
    bottombarvisibilitycommunicatorshell.cpp
    launchermodel.cpp
    )

add_library(Unity-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(Unity-qml
    ${QTDEE_LDFLAGS}
    ${UNITYCORE_LDFLAGS}
    ${Qt5DBus_LIBRARIES}
    ${Qt5Gui_LIBRARIES}
    )

qt5_use_modules(Unity-qml Qml)

file(GLOB Unity_QMLFILES
    qmldir
)

# copy qmldir file into build directory for shadow builds
add_custom_target(UnityQmlFiles ALL
    COMMAND cp ${Unity_QMLFILES} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${Unity_QMLFILES}
)

# create the Unity.qmltypes file
add_custom_target(Unity-qmltypes ALL
    COMMAND qmlplugindump -notrelocatable Unity 0.1 ${CMAKE_BINARY_DIR}/plugins > ${CMAKE_CURRENT_BINARY_DIR}/Unity.qmltypes
)
add_dependencies(Unity-qmltypes Unity-qml UnityQmlFiles)

install(TARGETS Unity-qml
    DESTINATION ${SHELL_APP_DIR}/plugins/Unity
    )

install(FILES ${Unity_QMLFILES}
    DESTINATION ${SHELL_APP_DIR}/plugins/Unity
    )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/Unity.qmltypes
    DESTINATION ${SHELL_APP_DIR}/plugins/Unity
    )
