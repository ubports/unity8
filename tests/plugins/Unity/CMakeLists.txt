pkg_check_modules(UNITYCORE REQUIRED unity-core-6.0)
pkg_check_modules(LIBUNITYPROTO REQUIRED unity-protocol-private)

include_directories(
    ${Unity-qml_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Unity
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBUNITYPROTO_INCLUDE_DIRS}
    ${UNITYCORE_INCLUDE_DIRS}
    )

macro(run_tests)
    set(_test_list "")
    foreach(_test ${ARGN})
        set(testCommand
                ${CMAKE_CURRENT_BINARY_DIR}/${_test}Exec
                -o ${CMAKE_BINARY_DIR}/${_test}.xml,xunitxml
                -o -,txt)
        add_test(NAME test${CLASSNAME}${_test} COMMAND ${testCommand})
        add_custom_target(${_test} ${testCommand})
        add_executable(${_test}Exec ${_test}.cpp previewbindingstest.cpp)
        qt5_use_modules(${_test}Exec Test Core Qml)
        set_tests_properties(test${CLASSNAME}${_test}
                PROPERTIES ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Unity:${LIBUNITYPROTO_LIBRARY_DIRS})

        target_link_libraries(${_test}Exec
            Unity-qml
            ${UNITYCORE_LDFLAGS}
            ${LIBUNITYPROTO_LDFLAGS}
            )

        set(_test_list "${_test_list};${_test}")
    endforeach()
endmacro(run_tests)

run_tests(
    previewbindingstest
    )
