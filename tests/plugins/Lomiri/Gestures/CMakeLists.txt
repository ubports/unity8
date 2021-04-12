include(QmlTest)

pkg_check_modules(LOMIRIGESTURES REQUIRED LomiriGestures)

# DANGER! DANGER! Using Qt's private API!
include_directories(
    SYSTEM
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${LOMIRIGESTURES_INCLUDE_DIRS}
    ${LOMIRIGESTURES_INCLUDEDIR}/LomiriGestures/${LOMIRIGESTURES_VERSION}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Gestures
    ${CMAKE_CURRENT_BINARY_DIR}
    )

macro(build_gesture_test CLASSNAME)
    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp GestureTest.cpp TestItem.cpp)
    target_link_libraries(${CLASSNAME}TestExec
        Qt5::Test Qt5::Core Qt5::Qml Qt5::Gui Qt5::Quick
        LomiriGesturesQml ${LOMIRIGESTURES_LIBRARIES}
    )
    install(TARGETS ${CLASSNAME}TestExec
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Lomiri/Gestures"
    )
    # To find libLomiriGestures.so
    set_target_properties(${CLASSNAME}TestExec PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}")
endmacro()

set(UNITY_IMPORT_PATHS
    ${CMAKE_BINARY_DIR}/tests/utils/modules
    ${UNITY_PLUGINPATH}
)

macro(add_gesture_unit_test CLASSNAME)
    build_gesture_test(${CLASSNAME})
    add_unity8_unittest(${CLASSNAME} ${CLASSNAME}TestExec
        ENVIRONMENT LD_LIBRARY_PATH=${UNITY_PLUGINPATH}/Lomiri/Gestures
        ${ARGN}
    )
endmacro()

macro(add_gesture_ui_test CLASSNAME)
    build_gesture_test(${CLASSNAME})
    add_unity8_uitest(${CLASSNAME} ${CLASSNAME}TestExec
        ENVIRONMENT LD_LIBRARY_PATH=${UNITY_PLUGINPATH}/Lomiri/Gestures
        ${ARGN}
    )
    add_manual_qml_test(. ${CLASSNAME} IMPORT_PATHS ${UNITY_IMPORT_PATHS})
endmacro()

add_qml_test_data(. empty.qml)
add_qml_test_data(. touchGateExample.qml)

add_gesture_ui_test(FloatingFlickable)
add_gesture_ui_test(PressedOutsideNotifier)
add_gesture_ui_test(TouchDispatcher)
add_gesture_ui_test(TouchGate)
add_gesture_unit_test(AxisVelocityCalculator)
add_gesture_ui_test(TouchGestureArea)
