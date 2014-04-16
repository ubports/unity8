# add_qml_test(path component_name [NO_ADD_TEST] [NO_TARGETS]
#              [TARGETS target1 [target2 [...]]]
#              [IMPORT_PATHS import_path1 [import_path2 [...]]
#              [PROPERTIES prop1 value1 [prop2 value2 [...]]])
#
# NO_ADD_TEST will prevent adding the test to the "test" target
# NO_TARGETS will prevent adding the test to any targets
# TARGETS lists the targets the test should be added to
# IMPORT_PATHS will pass those paths to qmltestrunner as "-import" arguments
# PROPERTIES will be set on the target and test target. See CMake's set_target_properties()
#
# Two targets will be created:
#   - testComponentName - Runs the test with qmltestrunner
#   - tryComponentName - Runs the test with uqmlscene, for manual interaction
#
# To change/set a default value for the whole test suite, prior to calling add_qml_test, set:
# qmltest_DEFAULT_NO_ADD_TEST (default: FALSE)
# qmltest_DEFAULT_TARGETS
# qmltest_DEFAULT_IMPORT_PATHS
# qmltest_DEFAULT_PROPERTIES

find_program(qmltestrunner_exe qmltestrunner)

if(NOT qmltestrunner_exe)
  msg(FATAL_ERROR "Could not locate qmltestrunner.")
endif()

set(qmlscene_exe ${CMAKE_BINARY_DIR}/tests/uqmlscene/uqmlscene)

macro(add_manual_qml_test SUBPATH COMPONENT_NAME)
    set(options NO_ADD_TEST NO_TARGETS)
    set(multi_value_keywords IMPORT_PATHS TARGETS PROPERTIES ENVIRONMENT)

    cmake_parse_arguments(qmltest "${options}" "" "${multi_value_keywords}" ${ARGN})

    set(qmlscene_TARGET try${COMPONENT_NAME})
    set(qmltest_FILE ${SUBPATH}/tst_${COMPONENT_NAME})

    set(qmlscene_imports "")
    if(NOT "${qmltest_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_IMPORT_PATHS})
            list(APPEND qmlscene_imports "-I")
            list(APPEND qmlscene_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    elseif(NOT "${qmltest_DEFAULT_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_DEFAULT_IMPORT_PATHS})
            list(APPEND qmlscene_imports "-I")
            list(APPEND qmlscene_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    endif()

    set(qmlscene_command
        env ${qmltest_ENVIRONMENT}
        ${qmlscene_exe} ${CMAKE_CURRENT_SOURCE_DIR}/${qmltest_FILE}.qml
            ${qmlscene_imports}
    )
    add_custom_target(${qmlscene_TARGET} ${qmlscene_command})

endmacro(add_manual_qml_test)

macro(add_qml_benchmark SUBPATH COMPONENT_NAME ITERATIONS)
    add_qml_test_internal(${SUBPATH} ${COMPONENT_NAME} ${ITERATIONS})
endmacro(add_qml_benchmark)

macro(add_qml_test SUBPATH COMPONENT_NAME)
    add_qml_test_internal(${SUBPATH} ${COMPONENT_NAME} 0)
endmacro(add_qml_test)

macro(add_qml_test_internal SUBPATH COMPONENT_NAME ITERATIONS)
    set(options NO_ADD_TEST NO_TARGETS)
    set(multi_value_keywords IMPORT_PATHS TARGETS PROPERTIES ENVIRONMENT)

    cmake_parse_arguments(qmltest "${options}" "" "${multi_value_keywords}" ${ARGN})

    set(qmltest_TARGET test${COMPONENT_NAME})
    set(qmltest_xvfb_TARGET xvfbtest${COMPONENT_NAME})
    set(qmltest_FILE ${SUBPATH}/tst_${COMPONENT_NAME})

    set(qmltestrunner_imports "")
    if(NOT "${qmltest_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_IMPORT_PATHS})
            list(APPEND qmltestrunner_imports "-import")
            list(APPEND qmltestrunner_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    elseif(NOT "${qmltest_DEFAULT_IMPORT_PATHS}" STREQUAL "")
        foreach(IMPORT_PATH ${qmltest_DEFAULT_IMPORT_PATHS})
            list(APPEND qmltestrunner_imports "-import")
            list(APPEND qmltestrunner_imports ${IMPORT_PATH})
        endforeach(IMPORT_PATH)
    endif()

    string(TOLOWER "${CMAKE_GENERATOR}" cmake_generator_lower)
    if(cmake_generator_lower STREQUAL "unix makefiles")
        set(function_ARGS $(FUNCTION))
    else()
        set(function_ARGS "")
    endif()

    if (${ITERATIONS} GREATER 0)
        set(ITERATIONS_STRING "-iterations" ${ITERATIONS})
    else()
        set(ITERATIONS_STRING "")
    endif()

    set(qmltest_command
        env ${qmltest_ENVIRONMENT}
        ${qmltestrunner_exe} -input ${CMAKE_CURRENT_SOURCE_DIR}/${qmltest_FILE}.qml
            ${qmltestrunner_imports}
            ${ITERATIONS_STRING}
            -o ${CMAKE_BINARY_DIR}/${qmltest_TARGET}.xml,xunitxml
            -o -,txt
            ${function_ARGS}
    )
    find_program( HAVE_GCC gcc )
    if (NOT ${HAVE_GCC} STREQUAL "")
        exec_program( gcc ARGS "-dumpmachine" OUTPUT_VARIABLE ARCH_TRIPLET )
        set(LD_PRELOAD_PATH "LD_PRELOAD=/usr/lib/${ARCH_TRIPLET}/mesa/libGL.so.1")
    endif()
    set(qmltest_xvfb_command
        env ${qmltest_ENVIRONMENT} ${LD_PRELOAD_PATH}
        xvfb-run --server-args "-screen 0 1024x768x24" --auto-servernum
        ${qmltestrunner_exe} -input ${CMAKE_CURRENT_SOURCE_DIR}/${qmltest_FILE}.qml
        ${qmltestrunner_imports}
            -o ${CMAKE_BINARY_DIR}/${qmltest_TARGET}.xml,xunitxml
            -o -,txt
            ${function_ARGS}
    )

    add_qmltest_target(${qmltest_TARGET} "${qmltest_command}" TRUE ${qmltest_NO_ADD_TEST})
    add_qmltest_target(${qmltest_xvfb_TARGET} "${qmltest_xvfb_command}" ${qmltest_NO_TARGETS} TRUE)
    add_manual_qml_test(${SUBPATH} ${COMPONENT_NAME} ${ARGN})
endmacro(add_qml_test_internal)

macro(add_binary_qml_test CLASS_NAME LD_PATH DEPS)
    set(testCommand
          LD_LIBRARY_PATH=${LD_PATH}
          ${CMAKE_CURRENT_BINARY_DIR}/${CLASS_NAME}TestExec
          -o ${CMAKE_BINARY_DIR}/${CLASSNAME}Test.xml,xunitxml
          -o -,txt)

    add_qmltest_target(test${CLASS_NAME} "${testCommand}" FALSE TRUE)
    add_dependencies(test${CLASS_NAME} ${CLASS_NAME}TestExec ${DEPS})

    find_program( HAVE_GCC gcc )
    if (NOT ${HAVE_GCC} STREQUAL "")
        exec_program( gcc ARGS "-dumpmachine" OUTPUT_VARIABLE ARCH_TRIPLET )
        set(LD_PRELOAD_PATH "LD_PRELOAD=/usr/lib/${ARCH_TRIPLET}/mesa/libGL.so.1")
    endif()
    set(xvfbtestCommand
          ${LD_PRELOAD_PATH}
          LD_LIBRARY_PATH=${LD_PATH}
          xvfb-run --server-args "-screen 0 1024x768x24" --auto-servernum
          ${CMAKE_CURRENT_BINARY_DIR}/${CLASS_NAME}TestExec
          -o ${CMAKE_BINARY_DIR}/${CLASS_NAME}Test.xml,xunitxml
          -o -,txt)

    add_qmltest_target(xvfbtest${CLASS_NAME} "${xvfbtestCommand}" FALSE TRUE)
    add_dependencies(qmluitests xvfbtest${CLASS_NAME})

    add_manual_qml_test(. ${CLASS_NAME} IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins)
endmacro(add_binary_qml_test)

macro(add_qmltest_target qmltest_TARGET qmltest_command qmltest_NO_TARGETS qmltest_NO_ADD_TEST)
    add_custom_target(${qmltest_TARGET} ${qmltest_command})

    if(NOT "${qmltest_PROPERTIES}" STREQUAL "")
        set_target_properties(${qmltest_TARGET} PROPERTIES ${qmltest_PROPERTIES})
    elseif(NOT "${qmltest_DEFAULT_PROPERTIES}" STREQUAL "")
        set_target_properties(${qmltest_TARGET} PROPERTIES ${qmltest_DEFAULT_PROPERTIES})
    endif()

    if("${qmltest_NO_ADD_TEST}" STREQUAL FALSE AND NOT "${qmltest_DEFAULT_NO_ADD_TEST}" STREQUAL "TRUE")
        add_test(${qmltest_TARGET} ${qmltest_command})

        if(NOT "${qmltest_UNPARSED_ARGUMENTS}" STREQUAL "")
            set_tests_properties(${qmltest_TARGET} PROPERTIES ${qmltest_PROPERTIES})
        elseif(NOT "${qmltest_DEFAULT_PROPERTIES}" STREQUAL "")
            set_tests_properties(${qmltest_TARGET} PROPERTIES ${qmltest_DEFAULT_PROPERTIES})
        endif()
    endif("${qmltest_NO_ADD_TEST}" STREQUAL FALSE AND NOT "${qmltest_DEFAULT_NO_ADD_TEST}" STREQUAL "TRUE")

    if("${qmltest_NO_TARGETS}" STREQUAL "FALSE")
        if(NOT "${qmltest_TARGETS}" STREQUAL "")
            foreach(TARGET ${qmltest_TARGETS})
                add_dependencies(${TARGET} ${qmltest_TARGET})
            endforeach(TARGET)
        elseif(NOT "${qmltest_DEFAULT_TARGETS}" STREQUAL "")
            foreach(TARGET ${qmltest_DEFAULT_TARGETS})
                add_dependencies(${TARGET} ${qmltest_TARGET})
            endforeach(TARGET)
        endif()
    endif("${qmltest_NO_TARGETS}" STREQUAL "FALSE")

endmacro(add_qmltest_target)
