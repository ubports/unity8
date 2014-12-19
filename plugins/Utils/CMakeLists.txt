# Dependencies
include(FindPkgConfig)

pkg_search_module(GIO REQUIRED gio-2.0)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${GIO_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    qlimitproxymodelqml.cpp
    qsortfilterproxymodelqml.cpp
    relativetimeformatter.cpp
    timeformatter.cpp
    unitymenumodelpaths.cpp
    windowkeysfilter.cpp
    easingcurve.cpp
    plugin.cpp
    )

add_library(Utils-qml SHARED
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(Utils-qml ${GIO_LDFLAGS})

# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(Utils-qml PROPERTIES COMPILE_FLAGS -fvisibility=default)

qt5_use_modules(Utils-qml Qml Quick DBus Network Gui)

add_unity8_plugin(Utils 0.1 Utils TARGETS Utils-qml)
