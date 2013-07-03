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

file(GLOB UbuntuGesture_QMLFILES
    qmldir
)

# copy qmldir file into build directory for shadow builds
add_custom_target(UbuntuGestureQmlFiles ALL
    COMMAND cp ${UbuntuGesture_QMLFILES} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${UbuntuGesture_QMLFILES}
)

# create the UbuntuGestures.qmltypes file
add_custom_target(UbuntuGesture-qmltypes ALL
    COMMAND qmlplugindump -notrelocatable Ubuntu.Gestures 0.1 ${CMAKE_BINARY_DIR}/plugins > ${CMAKE_CURRENT_BINARY_DIR}/UbuntuGestures.qmltypes
)
add_dependencies(UbuntuGesture-qmltypes UbuntuGestureQml UbuntuGestureQmlFiles)

install(TARGETS UbuntuGestureQml
    DESTINATION ${SHELL_APP_DIR}/plugins/Ubuntu/Gestures
    )

install(FILES ${UbuntuGesture_QMLFILES}
    DESTINATION ${SHELL_APP_DIR}/plugins/Ubuntu/Gestures
    )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/UbuntuGestures.qmltypes
    DESTINATION ${SHELL_APP_DIR}/plugins/Ubuntu/Gestures
    )
