set(LibLightDM_SOURCES
    Greeter.cpp
    UsersModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockLightDM SHARED ${LibLightDM_SOURCES})

qt5_use_modules(MockLightDM Gui)

set_target_properties(MockLightDM PROPERTIES
                      OUTPUT_NAME lightdm-qt5-3)

install(TARGETS MockLightDM
    DESTINATION ${SHELL_INSTALL_QML}/mocks/LightDM/IntegratedLightDM/liblightdm
    )
