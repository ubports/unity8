include(QmlPlugins)

add_definitions(-DQT_NO_KEYWORDS)

include_directories(
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(UnityTestQML_SOURCES
    testutil.cpp
    plugin.cpp
    TouchEventSequenceWrapper.cpp
)

add_library(UnityTestQml MODULE ${UnityTestQML_SOURCES})

qt5_use_modules(UnityTestQml Core Quick Test)

export_qmlfiles(Unity.Test Unity/Test)
export_qmlplugin(Unity.Test 0.1 Unity/Test TARGETS UnityTestQml)
