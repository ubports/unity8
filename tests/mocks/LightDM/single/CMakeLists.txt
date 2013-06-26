set(LibLightDM_SOURCES
    ../Greeter.cpp
    ../InfographicModel.cpp
    ../UsersModel.cpp
    GreeterPrivate.cpp
    InfographicModelPrivate.cpp
    UsersModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockLightDM-single SHARED ${LibLightDM_SOURCES})

qt5_use_modules(MockLightDM-single Gui)

set_target_properties(MockLightDM-single PROPERTIES
                      OUTPUT_NAME lightdm-qt5-2)

install(TARGETS MockLightDM-single
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/LightDM/single
    )
