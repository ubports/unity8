set(LibLightDM_SOURCES
    ../Greeter.cpp
    ../UsersModel.cpp
    ../InfographicModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    InfographicModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockLightDM-full SHARED ${LibLightDM_SOURCES})

qt5_use_modules(MockLightDM-full Gui)

set_target_properties(MockLightDM-full PROPERTIES
                      OUTPUT_NAME lightdm-qt5-2)

install(TARGETS MockLightDM-full
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/LightDM/full
    )
