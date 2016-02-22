pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)

set(LibLightDM_SOURCES
    Greeter.cpp
    UsersModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(integratedLightDM STATIC ${LibLightDM_SOURCES})
add_library(MockLightDM-demo-shared SHARED ${LibLightDM_SOURCES})

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${GLIB_INCLUDE_DIRS}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
)

target_link_libraries(integratedLightDM
    ${GLIB_LIBRARIES}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    -lpam
)
target_link_libraries(MockLightDM-demo-shared
    ${GLIB_LIBRARIES}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    -lpam
)

qt5_use_modules(integratedLightDM Concurrent Gui)
qt5_use_modules(MockLightDM-demo-shared Concurrent Gui)

set_target_properties(integratedLightDM PROPERTIES COMPILE_FLAGS -fPIC)
set_target_properties(MockLightDM-demo-shared PROPERTIES
                      OUTPUT_NAME lightdm-qt5-2)

install(TARGETS MockLightDM-demo-shared
    DESTINATION ${SHELL_INSTALL_QML}/mocks/IntegratedLightDM/demo
    )
