add_definitions(-DQT_NO_KEYWORDS)

set(UnityTestQML_SOURCES
    testutil.cpp
    plugin.cpp
    TouchEventSequenceWrapper.cpp
)

add_library(UnityTestQml MODULE ${UnityTestQML_SOURCES})

qt5_use_modules(UnityTestQml Core Quick Test)

# copy qml files into build directory for shadow builds
file(GLOB QML_JS_FILES *.js *.qml qmldir)

add_custom_target(UnityTestQmlJsFiles ALL
    COMMAND cp ${QML_JS_FILES} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${QML_JS_FILES}
)
