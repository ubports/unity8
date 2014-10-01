include(QmlTest)

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Ubuntu/Gestures
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    )

file(GLOB qmlFiles *.qml)
add_custom_target(UbuntuGesturesTestQmlFiles ALL
    COMMAND cp ${qmlFiles} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${qmlFiles}
)

add_definitions(-DUBUNTU_GESTURES_PLUGIN_DIR="${CMAKE_BINARY_DIR}/plugins")

macro(add_gesture_ui_test CLASSNAME)
    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp GestureTest.cpp)
    qt5_use_modules(${CLASSNAME}TestExec Test Core Qml Gui Quick)
    target_link_libraries(${CLASSNAME}TestExec UbuntuGesturesQml UbuntuGestures)

    add_binary_qml_test(${CLASSNAME} ${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures UbuntuGesturesTestQmlFiles)
    add_manual_qml_test(. ${CLASSNAME} IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins)
endmacro(add_gesture_ui_test)

macro(add_gesture_test CLASSNAME)
    set(testCommand
         ${CLASSNAME}TestExec -o ${CMAKE_BINARY_DIR}/test${CLASSNAME}.xml,xunitxml -o -,txt)

    add_test(NAME test${CLASSNAME} COMMAND ${testCommand})

    set_tests_properties(test${CLASSNAME} PROPERTIES
        ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures)

    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp)
    qt5_use_modules(${CLASSNAME}TestExec Test Core)
    target_link_libraries(${CLASSNAME}TestExec UbuntuGesturesQml)
endmacro(add_gesture_test)

add_gesture_ui_test(DirectionalDragArea)
add_gesture_ui_test(PressedOutsideNotifier)
add_gesture_ui_test(TouchGate)
add_gesture_test(Damper)
add_gesture_test(AxisVelocityCalculator)
