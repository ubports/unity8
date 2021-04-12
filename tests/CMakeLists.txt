include(QmlTest)

# QML tests that do not require graphical capabilities.
add_meta_test(unittests)

# QML tests that require graphical capabilities.
add_meta_test(uitests)
add_meta_test(xvfbuitests)

# Run our meta-meta tests serially because we don't need to nest
# parallelized tests.
add_meta_test(alltests SERIAL DEPENDS unittests uitests)
add_meta_test(xvfballtests SERIAL DEPENDS unittests xvfbuitests)

# Support libraries and plugins
add_subdirectory(mocks)
add_subdirectory(utils)
add_subdirectory(uqmlscene)

# Use our custom implementation of qmlscene and import dbus-test-runner
add_executable(qmlscene ALIAS uqmlscene)
import_executables(dbus-test-runner)
import_executables(qdbus-simple-test-runner)

set(LOMIRI_PLUGINPATH "${CMAKE_BINARY_DIR}/plugins" CACHE PATH "Path to pre-built lomiri plugin dir.")
set(LOMIRI_MOCKPATH "${CMAKE_BINARY_DIR}/tests/mocks" CACHE PATH "Path to pre-built lomiri mock dir.")

# Pre-built mocks have preference, pre-built plugins replace local build
set(LOMIRI_IMPORT_PATHS
    ${LOMIRI_MOCKPATH}
    ${CMAKE_BINARY_DIR}/tests/mocks
    ${CMAKE_BINARY_DIR}/tests/utils/modules
    ${LOMIRI_PLUGINPATH}
)
list(REMOVE_DUPLICATES LOMIRI_IMPORT_PATHS)
set(LOMIRI_IMPORT_PATHS ${LOMIRI_IMPORT_PATHS} CACHE INTERNAL "")

macro(lomiri_parse_arguments)
    cmake_parse_arguments(U8TEST
        "${QMLTEST_OPTIONS}"
        "${QMLTEST_SINGLE}"
        "${QMLTEST_MULTI}"
        ${ARGN}
    )

    set(ld_paths)
    list(APPEND ld_paths
        ${LOMIRI_MOCKPATH}/liblightdm
        ${LOMIRI_MOCKPATH}/libusermetrics
        ${LOMIRI_MOCKPATH}/WindowManager
    )

    string(REPLACE ";" ":" ld_library_path "${ld_paths}")
    set(ld_library_path LD_LIBRARY_PATH=${ld_library_path})

    set(U8TEST_ARGN "${ARGN}")

    set(environment
        LOMIRI_TESTING=1
        LANGUAGE=C
        LC_ALL=C.UTF-8
        ${ld_library_path}
    )
endmacro()


# add a non-graphical unit test
# see QmlTest.cmake for additional options
function(add_lomiri_unittest COMPONENT_NAME TARGET)
    lomiri_parse_arguments(${ARGN})
    add_executable_test(${COMPONENT_NAME} ${TARGET}
        ADD_TEST
        IMPORT_PATHS ${LOMIRI_IMPORT_PATHS}
        TARGETS unittests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    ${U8TEST_ENVIRONMENT}
                    QT_QPA_PLATFORM=minimal
                    UITK_ICON_THEME=suru
    )
endfunction()

# add a graphical unit test
function(add_lomiri_uitest COMPONENT_NAME TARGET)
    lomiri_parse_arguments(${ARGN})
    add_executable_test(${COMPONENT_NAME} ${TARGET}
        IMPORT_PATHS ${LOMIRI_IMPORT_PATHS}
        TARGETS uitests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    ${U8TEST_ENVIRONMENT}
                    UITK_ICON_THEME=suru
    )
endfunction()

# add a non-graphical qml unit test
function(add_lomiri_qmlunittest PATH COMPONENT_NAME)
    lomiri_parse_arguments(${ARGN})
    add_qml_unittest(${PATH} ${COMPONENT_NAME}
        ADD_TEST
        IMPORT_PATHS ${LOMIRI_IMPORT_PATHS}
        TARGET unittests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    ${U8TEST_ENVIRONMENT}
                    QT_QPA_PLATFORM=minimal
                    UITK_ICON_THEME=suru
    )
endfunction()

# add a graphical qml test
function(add_lomiri_qmltest PATH COMPONENT_NAME)
    lomiri_parse_arguments(${ARGN})
    add_qml_test(${PATH} ${COMPONENT_NAME}
        IMPORT_PATHS ${LOMIRI_IMPORT_PATHS}
        TARGETS uitests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    ${U8TEST_ENVIRONMENT}
                    UITK_ICON_THEME=suru
    )
endfunction()

# add a graphical qml benchmark
function(add_lomiri_qmlbenchmark PATH COMPONENT_NAME ITERATIONS)
    add_lomiri_qmltest(${PATH} ${COMPONENT_NAME} ITERATIONS ${ITERATIONS} ${ARGN})
endfunction()

# add files needed for qml tests, just here for better alignment with add_lomiri_qmltest
function(add_lomiri_qmltest_data PATH COMPONENT_NAME)
    add_qml_test_data("${PATH}" "${COMPONENT_NAME}")
endfunction()

# used to make dbus adaptor classes from xml to mock system services
if(DEFINED ENV{DEB_BUILD_MULTIARCH})
  set(QDBUSXML2CPP_EXECUTABLE "/usr/lib/$ENV{DEB_BUILD_MULTIARCH}/qt5/bin/qdbusxml2cpp")
else()
  FIND_PROGRAM(QDBUSXML2CPP_EXECUTABLE qdbusxml2cpp)
endif()

if(NOT QDBUSXML2CPP_EXECUTABLE)
    message(FATAL_ERROR "qdbusxml2cpp not found")
endif()

install(DIRECTORY data graphics
    DESTINATION "${SHELL_APP_DIR}/tests"
)


# Actual test definitions
add_subdirectory(plugins)
add_subdirectory(qmltests)
add_subdirectory(whitespace)
add_subdirectory(imports)
add_subdirectory(copyright)
