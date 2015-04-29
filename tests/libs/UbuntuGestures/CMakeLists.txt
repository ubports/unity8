include_directories(
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
    ${CMAKE_CURRENT_BINARY_DIR}
    )

macro(add_gesture_test CLASSNAME)
    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp)
    qt5_use_modules(${CLASSNAME}TestExec Test Core Gui Quick)
    target_link_libraries(${CLASSNAME}TestExec UbuntuGestures)

    add_unity8_unittest(${CLASSNAME} ${CLASSNAME}TestExec
        ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/libs/UbuntuGestures
    )
endmacro(add_gesture_test)

add_gesture_test(TouchRegistry)
