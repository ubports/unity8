include_directories(
    ${UtilsQmlPlugin_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Utils
    ${CMAKE_CURRENT_BINARY_DIR}
    )

macro(run_tests)
    set(_test_list "")
    foreach(_test ${ARGN})
        set(testCommand ${CMAKE_CURRENT_BINARY_DIR}/${_test}Exec
              -o ${CMAKE_BINARY_DIR}/${_test}.xml,xunitxml
              -o -,txt)
        add_test(NAME ${_test} COMMAND ${testCommand})
        add_custom_target(${_test} env "LC_ALL=C.UTF-8" ${testCommand})
        add_executable(${_test}Exec ${_test}.cpp modeltest.cpp)
        qt5_use_modules(${_test}Exec Test Core Qml)
        target_link_libraries(${_test}Exec
            Utils-qml
            )
        set(_test_list "${_test_list};${_test}")
    endforeach()
endmacro(run_tests)

run_tests(
    qlimitproxymodeltest
    qsortfilterproxymodeltest
    timeformattertest
    )

# plain qml test
set(qmltest_DEFAULT_TARGETS qmltests)
set(qmltest_DEFAULT_PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=minimal")
add_qml_test(. UtilsStyle IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins)
