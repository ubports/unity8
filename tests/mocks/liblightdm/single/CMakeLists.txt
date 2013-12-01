set(LibLightDM_SOURCES
    ../Greeter.cpp
    ../UsersModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockLightDM-single SHARED ${LibLightDM_SOURCES})

qt5_use_modules(MockLightDM-single Gui)

set_target_properties(MockLightDM-single PROPERTIES
                      OUTPUT_NAME lightdm-qt5-3
                      SOVERSION 0)

install(TARGETS MockLightDM-single
    DESTINATION ${SHELL_INSTALL_QML}/mocks/liblightdm/single
    )
