set(CMAKE_AUTOMOC ON)

include(FindPkgConfig)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

set(FakeUbuntuApplicationQml_SOURCES
    plugin.cpp
    ApplicationInfo.cpp
    ApplicationImage.cpp
    ApplicationListModel.cpp
    ApplicationManager.cpp
)

add_library(FakeUbuntuApplicationQml MODULE ${FakeUbuntuApplicationQml_SOURCES})

qt5_use_modules(FakeUbuntuApplicationQml Core Quick)

# copy files into build directory for shadow builds
add_custom_target(UbuntuAppQmlDirFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/qmldir" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS qmldir
)
add_custom_target(InputFilterAreaQmlFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/InputFilterArea.qml" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS InputFilterArea.qml
)

install(TARGETS FakeUbuntuApplicationQml
    DESTINATION ${SHELL_APP_DIR}/plugins/mocks/Ubuntu/Application
    )

install(FILES qmldir InputFilterArea.qml
    DESTINATION ${SHELL_APP_DIR}/plugins/mocks/Ubuntu/Application
    )
