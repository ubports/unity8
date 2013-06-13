########## tst_DirectionalDragArea

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Ubuntu/Gestures
    ${CMAKE_CURRENT_BINARY_DIR}
    )

set(testCommand
      LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures
      ${CMAKE_CURRENT_BINARY_DIR}/DirectionalDragAreaTestExec
      -o ${CMAKE_BINARY_DIR}/DirectionalDragAreaTest.xml,xunitxml
      -o -,txt)

add_custom_target(testDirectionalDragArea ${testCommand})
add_dependencies(qmluitests testDirectionalDragArea)
add_dependencies(testDirectionalDragArea DirectionalDragAreaTestExec UbutunGesturesTestQmlFiles)

add_executable(DirectionalDragAreaTestExec tst_DirectionalDragArea.cpp)
qt5_use_modules(DirectionalDragAreaTestExec Test Core Qml Gui Quick)
target_link_libraries(DirectionalDragAreaTestExec UbuntuGestureQml)

add_definitions(-DUBUNTU_GESTURES_PLUGIN_DIR="${CMAKE_BINARY_DIR}/plugins")

file(GLOB qmlFiles *.qml)
add_custom_target(UbuntuGesturesTestQmlFiles ALL
    COMMAND cp ${qmlFiles} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${qmlFiles}
)

########## other tests

macro(add_gesture_test CLASSNAME)
    set(testCommand
         ${CLASSNAME}TestExec -o ${CMAKE_BINARY_DIR}/test${CLASSNAME}.xml,xunitxml -o -,txt)

    add_test(NAME test${CLASSNAME} COMMAND ${testCommand})

    set_tests_properties(test${CLASSNAME} PROPERTIES
        ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures)

    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp)
    qt5_use_modules(${CLASSNAME}TestExec Test Core)
    target_link_libraries(${CLASSNAME}TestExec UbuntuGestureQml)
endmacro(add_gesture_test)

add_gesture_test(Damper)
add_gesture_test(AxisVelocityCalculator)
