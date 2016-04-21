include_directories(
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
    ${CMAKE_CURRENT_BINARY_DIR}
    )

macro(add_gesture_test CLASSNAME)
    add_executable(${CLASSNAME}TestExec tst_${CLASSNAME}.cpp)
    qt5_use_modules(${CLASSNAME}TestExec Test Core Gui Quick)
    target_link_libraries(${CLASSNAME}TestExec UbuntuGestures)
    install(TARGETS ${CLASSNAME}TestExec
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/libs/UbuntuGestures"
    )
    set_target_properties(${CLASSNAME}TestExec PROPERTIES
        INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}"
    )

    add_unity8_unittest(${CLASSNAME} ${CLASSNAME}TestExec)
endmacro(add_gesture_test)

add_gesture_test(TouchRegistry)
