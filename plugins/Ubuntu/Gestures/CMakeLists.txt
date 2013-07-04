set(CMAKE_AUTOMOC ON)

include(FindPkgConfig)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

set(UbuntuGestureQml_SOURCES
    plugin.cpp
    AxisVelocityCalculator.cpp
    Direction.cpp
    DirectionalDragArea.cpp
)

add_definitions(-DUBUNTUGESTURES_LIBRARY)

add_library(UbuntuGestureQml MODULE ${UbuntuGestureQml_SOURCES})

qt5_use_modules(UbuntuGestureQml Core Quick)

# So that Foo.cpp can #include "Foo.moc"
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# copy files into build directory for shadow builds
add_custom_target(UbuntuGestureQmlDirFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/qmldir" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS qmldir
)

install(TARGETS UbuntuGestureQml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/Ubuntu/Gestures
    )

install(FILES qmldir
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/Ubuntu/Gestures
    )
