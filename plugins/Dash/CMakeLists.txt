# There's no cmake var for v8 include path :-/
# so create one
LIST(GET Qt5Core_INCLUDE_DIRS 0 QtCoreDir0)
if(${Qt5Core_VERSION_STRING} VERSION_LESS "5.1.0")
    SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/../QtV8/${Qt5Core_VERSION_STRING}/QtV8)
else()
    SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/QtV8/${Qt5Core_VERSION_STRING}/QtV8)
endif()

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${Qt5V8_PRIVATE_INCLUDE_DIR}
)

remove_definitions(-DQT_NO_KEYWORDS)

set(QMLPLUGIN_SRC
    plugin.cpp
    listviewwithpageheader.cpp
    abstractdashview.cpp
    verticaljournal.cpp
    horizontaljournal.cpp
    organicgrid.cpp
    )

add_library(Dash-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(Dash-qml
    ${Qt5Gui_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    )

qt5_use_modules(Dash-qml Qml Quick Concurrent)

add_unity8_plugin(Dash 0.1 Dash TARGETS Dash-qml)
