include_directories(
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
# FIXME There's no cmake var for this :-/
    /usr/include/qt5/QtV8/5.0.2/QtV8
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader
    ${CMAKE_CURRENT_BINARY_DIR}
    )

remove_definitions(-DQT_NO_KEYWORDS)

add_definitions(-DLISTVIEWWITHPAGEHEADER_FOLDER="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DBUILT_PLUGINS_DIR="${CMAKE_BINARY_DIR}/plugins")

macro(run_tests)
    set(_test_list "")
    foreach(_test ${ARGN})
        set(testCommand ${CMAKE_CURRENT_BINARY_DIR}/${_test}Exec
              -o ${CMAKE_BINARY_DIR}/${_test}.xml,xunitxml
              -o -,txt)
        add_test(NAME ${_test} COMMAND ${testCommand})
        add_custom_target(${_test} ${testCommand})
        add_executable(${_test}Exec ${_test}.cpp ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader/listviewwithpageheader.cpp)
        qt5_use_modules(${_test}Exec Test Core Qml)
        target_link_libraries(${_test}Exec
            ${Qt5Gui_LIBRARIES}
            ${Qt5Quick_LIBRARIES}
            )
        set(_test_list "${_test_list};${_test}")
    endforeach()
endmacro(run_tests)

run_tests(
    listviewwithpageheadertest
    )
