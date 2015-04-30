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

# Base/default values
set(base_environment
    UNITY_TESTING=1
    LANGUAGE=C
    LC_ALL=C.UTF-8
)

set(import_paths
    ${CMAKE_BINARY_DIR}/tests/mocks
    ${CMAKE_BINARY_DIR}/tests/utils/modules
    ${CMAKE_BINARY_DIR}/plugins
)


# add a non-graphical unit test
# see QmlTest.cmake for additional options
function(add_unity8_unittest COMPONENT_NAME TARGET)
    cmake_parse_arguments(U8TEST "${QMLTEST_OPTIONS}" "${QMLTESTS_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    add_executable_test(${COMPONENT_NAME} ${TARGET}
        ADD_TEST
        TARGETS unittests
        ${ARGN}
        ENVIRONMENT ${base_environment}
                    QT_QPA_PLATFORM=minimal
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a graphical unit test
function(add_unity8_uitest COMPONENT_NAME TARGET)
    cmake_parse_arguments(U8TEST "${QMLTEST_OPTIONS}" "${QMLTESTS_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    add_executable_test(${COMPONENT_NAME} ${TARGET}
        TARGETS uitests
        ${ARGN}
        ENVIRONMENT ${base_environment}
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a non-graphical qml unit test
function(add_unity8_qmlunittest PATH COMPONENT_NAME)
    cmake_parse_arguments(U8TEST "${QMLTEST_OPTIONS}" "${QMLTESTS_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    add_qml_unittest(${PATH} ${COMPONENT_NAME}
        ADD_TEST
        IMPORT_PATHS ${import_paths}
        TARGET unittests
        ${ARGN}
        ENVIRONMENT ${base_environment}
                    QT_QPA_PLATFORM=minimal
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a graphical qml test
function(add_unity8_qmltest PATH COMPONENT_NAME)
    cmake_parse_arguments(U8TEST "${QMLTEST_OPTIONS}" "${QMLTESTS_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    add_qml_test(${PATH} ${COMPONENT_NAME}
        IMPORT_PATHS ${import_paths}
        TARGETS uitests
        ${ARGN}
        ENVIRONMENT ${base_environment}
                    LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/libusermetrics:${CMAKE_BINARY_DIR}/tests/mocks/LightDM/liblightdm:${CMAKE_BINARY_DIR}/tests/mocks/QMenuModel
                    ${U8TEST_ENVIRONMENT}
    )
endfunction()

# add a graphical qml benchmark
function(add_unity8_qmlbenchmark PATH COMPONENT_NAME ITERATIONS)
    add_unity8_qmltest(${PATH} ${COMPONENT_NAME} ${ARGN} ITERATIONS ${ITERATIONS})
endfunction()


# Actual test definitions
add_subdirectory(libs)
add_subdirectory(plugins)
add_subdirectory(qmltests)
add_subdirectory(whitespace)
