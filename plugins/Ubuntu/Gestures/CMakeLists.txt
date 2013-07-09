# export_qmlplugin macro
include(Plugins)

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

# export the qmldir and qmltypes files
export_qmlplugin(Ubuntu.Gestures 0.1 Ubuntu/Gestures TARGETS UbuntuGestureQml)
