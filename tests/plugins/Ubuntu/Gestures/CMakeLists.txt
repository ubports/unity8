include(QmlTest)

# DANGER! DANGER! Using Qt's private API!
include_directories(
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
)

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Ubuntu/Gestures
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    )

export_qmlfiles(UbuntuGesturesTest .)

macro(build_gesture_test CLASSNAME)
    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp GestureTest.cpp TestItem.cpp)
    qt5_use_modules(${CLASSNAME}TestExec Test Core Qml Gui Quick)
    target_link_libraries(${CLASSNAME}TestExec UbuntuGesturesQml UbuntuGestures)
endmacro()

set(UNITY_IMPORT_PATHS
    ${CMAKE_BINARY_DIR}/tests/utils/modules
    ${UNITY_PLUGINPATH}
)

macro(add_gesture_unit_test CLASSNAME)
    build_gesture_test(${CLASSNAME})
    add_unity8_unittest(${CLASSNAME} ${CLASSNAME}TestExec
        ENVIRONMENT LD_LIBRARY_PATH=${UNITY_PLUGINPATH}/Ubuntu/Gestures
        DEPENDS UbuntuGesturesTest-qmlfiles
        ${ARGN}
    )
endmacro()

macro(add_gesture_ui_test CLASSNAME)
    build_gesture_test(${CLASSNAME})
    add_unity8_uitest(${CLASSNAME} ${CLASSNAME}TestExec
        ENVIRONMENT LD_LIBRARY_PATH=${UNITY_PLUGINPATH}/Ubuntu/Gestures
        DEPENDS UbuntuGesturesTest-qmlfiles
        ${ARGN}
    )
    add_manual_qml_test(. ${CLASSNAME} IMPORT_PATHS ${UNITY_IMPORT_PATHS})
endmacro()

add_gesture_ui_test(DirectionalDragArea)
add_gesture_ui_test(FloatingFlickable)
add_gesture_ui_test(PressedOutsideNotifier)
add_gesture_ui_test(TouchDispatcher)
add_gesture_ui_test(TouchGate)
add_gesture_unit_test(Damper)
add_gesture_unit_test(AxisVelocityCalculator)
add_gesture_ui_test(TouchGestureArea)
