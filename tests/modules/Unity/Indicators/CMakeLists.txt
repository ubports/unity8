include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../../modules/Unity/Indicators
    )

macro(run_tests)
    set(_test_list "")
    foreach(_test ${ARGN})
        set(testCommand ${CMAKE_CURRENT_BINARY_DIR}/${_test}Exec
              -o ${CMAKE_BINARY_DIR}/${_test}.xml,xunitxml
              -o -,txt)
        add_test(NAME ${_test} COMMAND ${testCommand})
        add_custom_target(${_test} ${testCommand})
        add_executable(${_test}Exec ${_test}.cpp
            )
        qt5_use_modules(${_test}Exec Test Core Qml)
        target_link_libraries(${_test}Exec
            IndicatorsQml
            )
        set(_test_list "${_test_list};${_test}")
    endforeach()
endmacro(run_tests)

run_tests(
    indicatorsmanagertest
    indicatorsmodeltest
    )
