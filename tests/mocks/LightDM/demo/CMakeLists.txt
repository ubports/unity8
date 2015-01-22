pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)

set(LibLightDM_SOURCES
    ../Greeter.cpp
    ../UsersModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockLightDM-demo STATIC ${LibLightDM_SOURCES})
add_library(MockLightDM-demo-shared SHARED ${LibLightDM_SOURCES})

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
)

target_link_libraries(MockLightDM-demo
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    -lpam
)
target_link_libraries(MockLightDM-demo-shared
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    -lpam
)

qt5_use_modules(MockLightDM-demo Concurrent Gui)
qt5_use_modules(MockLightDM-demo-shared Concurrent Gui)

set_target_properties(MockLightDM-demo PROPERTIES COMPILE_FLAGS -fPIC)
set_target_properties(MockLightDM-demo-shared PROPERTIES
                      OUTPUT_NAME lightdm-qt5-2)

install(TARGETS MockLightDM-demo-shared
    DESTINATION ${SHELL_INSTALL_QML}/mocks/LightDM/demo
    )
