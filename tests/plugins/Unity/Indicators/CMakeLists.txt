pkg_check_modules(GLIB REQUIRED glib-2.0>=2.32)
pkg_check_modules(GIO REQUIRED gio-2.0>=2.32)
pkg_check_modules(QMENUMODEL REQUIRED qmenumodel)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../../plugins/Unity/Indicators
    ${GLIB_INCLUDE_DIRS}
    ${GIO_INCLUDE_DIRS}
    ${QMENUMODEL_INCLUDE_DIRS}
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
            ${GLIB_LIBRARIES}
            ${GIO_LIBRARIES}
            ${QMENUMODEL_LDFLAGS}
            )
        set(_test_list "${_test_list};${_test}")
    endforeach()
endmacro(run_tests)

run_tests(
    indicatorsmanagertest
    indicatorsmodeltest
    menucontentactivatortest
    unitymenumodelstacktest
    )
