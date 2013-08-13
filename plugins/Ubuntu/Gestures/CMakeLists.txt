# export_qmlplugin macro
include(Plugins)

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

# export the qmldir qmltypes and plugin files
export_qmlfiles(Ubuntu.Gestures Ubuntu/Gestures)
export_qmlplugin(Ubuntu.Gestures 0.1 Ubuntu/Gestures TARGETS UbuntuGestureQml)
