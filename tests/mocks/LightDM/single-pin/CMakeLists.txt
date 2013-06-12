set(LibLightDM_SOURCES
    ../Greeter.cpp
    ../UsersModel.cpp
    ../InfographicModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    InfographicModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )


add_library(MockLightDM-single-pin SHARED ${LibLightDM_SOURCES})

qt5_use_modules(MockLightDM-single-pin Gui)

set_target_properties(MockLightDM-single-pin PROPERTIES
                      OUTPUT_NAME lightdm-qt5-2)

install(TARGETS MockLightDM-single-pin
    DESTINATION ${SHELL_APP_DIR}/plugins/mocks/LightDM/single-pin
    )
