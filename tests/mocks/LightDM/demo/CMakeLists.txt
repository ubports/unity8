pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)

set(LibLightDM_SOURCES
    ../Greeter.cpp
    ../UsersModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockLightDM-demo STATIC ${LibLightDM_SOURCES})

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
)

target_link_libraries(MockLightDM-demo
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    -lpam
)

qt5_use_modules(MockLightDM-demo Concurrent Gui)
