include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Utils
)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${GIO_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    ${CMAKE_SOURCE_DIR}/plugins/Utils/activefocuslogger.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qlimitproxymodelqml.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitymenumodelpaths.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/windowinputfilter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/easingcurve.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/inputwatcher.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/timezoneFormatter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/applicationsfiltermodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/inputeventgenerator.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/deviceconfigparser.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/globalfunctions.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    constants.cpp
    plugin.cpp
    windowstatestorage.cpp
    URLDispatcher.cpp
    )

add_library(FakeUtils-qml SHARED
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(FakeUtils-qml ${GIO_LDFLAGS})

# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(FakeUtils-qml PROPERTIES COMPILE_FLAGS -fvisibility=default)

qt5_use_modules(FakeUtils-qml Qml Quick DBus Network Gui)

add_unity8_mock(Utils 0.1 Utils TARGETS FakeUtils-qml)
