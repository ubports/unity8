include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/tests/mocks
    )

add_executable(TopLevelWindowModelTestExec
    tst_TopLevelWindowModel.cpp
    UnityApplicationMocks.h

    ${CMAKE_SOURCE_DIR}/tests/mocks/Unity/Application/MirSurfaceListModel.cpp

    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/SurfaceManagerInterface.h
    )
qt5_use_modules(TopLevelWindowModelTestExec Test Core Gui Qml Quick)

target_link_libraries(TopLevelWindowModelTestExec windowmanager-qml)

install(TARGETS TopLevelWindowModelTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/WindowManager"
)

# To find libwindowmanager-qml.so
set_target_properties(TopLevelWindowModelTestExec PROPERTIES
        INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}")

add_unity8_unittest(TopLevelWindowModel TopLevelWindowModelTestExec
    ENVIRONMENT LD_LIBRARY_PATH=${UNITY_PLUGINPATH}/WindowManager
)
