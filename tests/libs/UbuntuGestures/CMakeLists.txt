include_directories(
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
    ${CMAKE_CURRENT_BINARY_DIR}
    )

macro(add_gesture_test CLASSNAME)
    set(testCommand
         ${CLASSNAME}TestExec -o ${CMAKE_BINARY_DIR}/test${CLASSNAME}.xml,xunitxml -o -,txt)

    add_test(NAME test${CLASSNAME} COMMAND ${testCommand})

    set_tests_properties(test${CLASSNAME} PROPERTIES
        ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/libs/UbuntuGestures)

    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp)
    qt5_use_modules(${CLASSNAME}TestExec Test Core Gui Quick)
    target_link_libraries(${CLASSNAME}TestExec UbuntuGestures)
endmacro(add_gesture_test)

add_gesture_test(TouchRegistry)
