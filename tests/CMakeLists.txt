include(QmlTest)

# QML tests that do not require graphical capabilities.
add_custom_target(unittests)

# QML tests that require graphical capabilities.
add_custom_target(uitests)
add_custom_target(xvfbuitests)

add_custom_target(alltests)
add_dependencies(alltests unittests uitests)

add_custom_target(xvfballtests)
add_dependencies(xvfballtests unittests xvfbuitests)

# Support libraries and plugins
add_subdirectory(mocks)
add_subdirectory(utils)
add_subdirectory(uqmlscene)

# Use our custom implementation of qmlscene and import dbus-test-runner
add_executable(qmlscene ALIAS uqmlscene)
import_executables(dbus-test-runner)

set(UNITY_PLUGINPATH "${CMAKE_BINARY_DIR}/plugins" CACHE PATH "Path to pre-built unity8 plugin dir.")
set(UNITY_MOCKPATH "${CMAKE_BINARY_DIR}/tests/mocks" CACHE PATH "Path to pre-built unity8 mock dir.")

# Pre-built mocks have preference, pre-built plugins replace local build
set(UNITY_IMPORT_PATHS
    ${UNITY_MOCKPATH}
    ${CMAKE_BINARY_DIR}/tests/mocks
    ${CMAKE_BINARY_DIR}/tests/utils/modules
    ${UNITY_PLUGINPATH}
)
list(REMOVE_DUPLICATES UNITY_IMPORT_PATHS)
set(UNITY_IMPORT_PATHS ${UNITY_IMPORT_PATHS} CACHE INTERNAL "")

macro(unity8_parse_arguments)
    cmake_parse_arguments(U8TEST
        "${QMLTEST_OPTIONS};LIGHTDM"
        "${QMLTEST_SINGLE}"
        "${QMLTEST_MULTI}"
        ${ARGN}
    )

    set(ld_paths)
    if(U8TEST_LIGHTDM)
        list(APPEND ld_paths
            ${UNITY_MOCKPATH}/libusermetrics
            ${UNITY_MOCKPATH}/LightDM/IntegratedLightDM/liblightdm
        )
    endif()

    if(ld_paths)
        string(REPLACE ";" ":" ld_library_path "${ld_paths}")
        set(ld_library_path LD_LIBRARY_PATH=${ld_library_path})
    endif()

    set(U8TEST_ARGN "${ARGN}")
    list(REMOVE_ITEM U8TEST_ARGN LIGHTDM)

    set(environment
        UNITY_TESTING=1
        LANGUAGE=C
        LC_ALL=C.UTF-8
        ${ld_library_path}
    )
endmacro()


# add a non-graphical unit test
# see QmlTest.cmake for additional options
function(add_unity8_unittest COMPONENT_NAME TARGET)
    unity8_parse_arguments(${ARGN})
    add_executable_test(${COMPONENT_NAME} ${TARGET}
        ADD_TEST
        IMPORT_PATHS ${UNITY_IMPORT_PATHS}
        TARGETS unittests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    QT_QPA_PLATFORM=minimal
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a graphical unit test
function(add_unity8_uitest COMPONENT_NAME TARGET)
    unity8_parse_arguments(${ARGN})
    add_executable_test(${COMPONENT_NAME} ${TARGET}
        IMPORT_PATHS ${UNITY_IMPORT_PATHS}
        TARGETS uitests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a non-graphical qml unit test
function(add_unity8_qmlunittest PATH COMPONENT_NAME)
    unity8_parse_arguments(${ARGN})
    add_qml_unittest(${PATH} ${COMPONENT_NAME}
        ADD_TEST
        IMPORT_PATHS ${UNITY_IMPORT_PATHS}
        TARGET unittests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    QT_QPA_PLATFORM=minimal
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a graphical qml test
function(add_unity8_qmltest PATH COMPONENT_NAME)
    unity8_parse_arguments(${ARGN})
    add_qml_test(${PATH} ${COMPONENT_NAME}
        IMPORT_PATHS ${UNITY_IMPORT_PATHS}
        TARGETS uitests
        ${U8TEST_ARGN}
        ENVIRONMENT ${environment}
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a graphical qml benchmark
function(add_unity8_qmlbenchmark PATH COMPONENT_NAME ITERATIONS)
    add_unity8_qmltest(${PATH} ${COMPONENT_NAME} ITERATIONS ${ITERATIONS} ${ARGN})
endfunction()


# Actual test definitions
add_subdirectory(libs)
add_subdirectory(plugins)
add_subdirectory(qmltests)
add_subdirectory(whitespace)
add_subdirectory(imports)
