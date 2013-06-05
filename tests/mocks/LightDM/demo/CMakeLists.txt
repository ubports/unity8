set(LibLightDM_SOURCES
    ../Greeter.cpp
    ../UsersModel.cpp
    ../InfographicModel.cpp
    GreeterPrivate.cpp
    UsersModelPrivate.cpp
    InfographicModelPrivate.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockLightDM-demo STATIC ${LibLightDM_SOURCES})

qt5_use_modules(MockLightDM-demo Gui)
