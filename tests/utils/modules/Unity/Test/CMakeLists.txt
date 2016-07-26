include(QmlPlugins)

add_definitions(-DQT_NO_KEYWORDS)

pkg_check_modules(UBUNTUGESTURES REQUIRED UbuntuGestures)

include_directories(
    ${CMAKE_SOURCE_DIR}/src
)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${UBUNTUGESTURES_INCLUDE_DIRS}
)

set(UnityTestQML_SOURCES
    testutil.cpp
    plugin.cpp
    TouchEventSequenceWrapper.cpp
)

if (ENABLE_TOUCH_EMULATION)
    set(UnityTestQML_SOURCES ${UnityTestQML_SOURCES} ${CMAKE_SOURCE_DIR}/src/MouseTouchAdaptor.cpp)
endif()

add_library(UnityTestQml MODULE ${UnityTestQML_SOURCES})
target_link_libraries(UnityTestQml ${UBUNTUGESTURES_LIBRARIES})

if (ENABLE_TOUCH_EMULATION)
    target_link_libraries(UnityTestQml ${MOUSETOUCHADAPTOR_LIBS_LDFLAGS})
endif()

qt5_use_modules(UnityTestQml Core Quick Test)

export_qmlfiles(Unity.Test Unity/Test)
export_qmlplugin(Unity.Test 0.1 Unity/Test TARGETS UnityTestQml)
