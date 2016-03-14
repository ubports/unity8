# If you need to override the qmlscene or qmltestrunner executables,
# create the corresponding executable target.

# These functions respect the global STDOUT_LOGGER and ARTIFACTS_DIR variables.

# You can use those with cmake_parse_arguments
# if you need to wrap and mangle arguments.
set(QMLTEST_OPTIONS ADD_TEST CACHE INTERNAL "")
set(QMLTEST_SINGLE ITERATIONS ARG_PREFIX CACHE INTERNAL "")
set(QMLTEST_MULTI ARGS ENVIRONMENT DEPENDS IMPORT_PATHS TARGETS CACHE INTERNAL "")

# import_executables(name1 [name2 [...]]
#    [OPTIONAL]                           # continue when not found
# )
#
# This will find the named executables and import them
# to an imported target of the same name.

function(import_executables)
    cmake_parse_arguments(QMLTEST "OPTIONAL" "" "" ${ARGN})

    foreach(NAME ${QMLTEST_UNPARSED_ARGUMENTS})
        if(NOT TARGET ${NAME})
            add_executable(${NAME} IMPORTED GLOBAL)
            find_program(${NAME}_exe ${NAME})

            if(NOT QMLTEST_OPTIONAL AND NOT ${NAME}_exe)
                message(FATAL_ERROR "Could not locate ${NAME}.")
            elseif(NOT ${NAME}_exe)
                message(STATUS "Could not locate ${NAME}, skipping.")
            else()
                set_target_properties(${NAME} PROPERTIES IMPORTED_LOCATION ${${NAME}_exe})
            endif()
        endif()
    endforeach()
endfunction()


# add_qml_test(path component_name
#     [...]
# )
#
# Add test targets for ${component_name} under ${path}. It's assumed
# that the test file is named ${path}/tst_${component_name}.qml.
#
# This function wraps add_manual_qml_test and add_qml_unittest,
# see below for available arguments.

function(add_qml_test PATH COMPONENT_NAME)
    cmake_parse_arguments(QMLTEST "${QMLTEST_OPTIONS}" "${QMLTEST_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    mangle_arguments()

    add_qml_unittest(${ARGV})
    add_manual_qml_test(${ARGV})
endfunction()


# add_qml_unittest(path component_name
#     [...]
# )
#
# Add test targets for ${component_name} under ${path}. It's assumed
# that the test file is named ${path}/tst_${component_name}.qml.
#
# This function wraps add_executable_test, see below for available arguments.

function(add_qml_unittest PATH COMPONENT_NAME)
    import_executables(qmltestrunner)

    add_executable_test(${COMPONENT_NAME} qmltestrunner
        ${ARGN}
        ARGS -input ${CMAKE_CURRENT_SOURCE_DIR}/${PATH}/tst_${COMPONENT_NAME}.qml ${QMLTEST_ARGS}
    )
endfunction()


# add_manual_qml_test(path component_name
#     [...]
# )
#
# Add manual test targets for ${component_name} under ${path}. It's assumed
# that the test file is named ${path}/tst_${component_name}.qml.
#
# This function wraps add_manual_test, see below for available arguments.

function(add_manual_qml_test PATH COMPONENT_NAME)
    import_executables(qmlscene)
    cmake_parse_arguments(QMLTEST "${QMLTEST_OPTIONS}" "${QMLTEST_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})

    add_manual_test(${COMPONENT_NAME} qmlscene
        ${ARGN}
        ARGS ${CMAKE_CURRENT_SOURCE_DIR}/${PATH}/tst_${COMPONENT_NAME}.qml ${QMLTEST_ARGS}
    )
endfunction()


# add_executable_test(target component_name
#     [...]                              # see doc for add_manual_qml_test for common arguments
#     [ADD_TEST]                         # whether to add to the "test" target
#     [ARG_PREFIX arg_prefix]            # prefix logging arguments with this string
#     [ARGS] arg1 [arg2 [...]]           # pass these arguments to the test executable
#     [TARGETS target1 [target2 [...]]]  # make the listed targets depend on this test
#                                        # if a corresponding xvfbtarget1, xvfbtarget2 etc. exists,
#                                        # this test running under xvfb will be added as a dependency
#                                        # of those targets
#     [ITERATIONS count]                 # run this test as a benchmark for ${count} iterations
# )
#
# Logging options in the standard form of "-o filename,format"
# will be appended to the arguments list, prefixed with ARG_PREFIX.
# XUnitXML files will be stored in current binary dir or under
# ARTIFACTS_DIR, if set.
#
# Three targets will be created:
#   - test${component_name} - Runs the test
#   - xvfbtest${component_name} - Runs the test under xvfb
#   - gdbtest${component_name} - Runs the test under gdb

function(add_executable_test COMPONENT_NAME TARGET)
    import_executables(gdb xvfb-run OPTIONAL)

    cmake_parse_arguments(QMLTEST "${QMLTEST_OPTIONS}" "${QMLTEST_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    mangle_arguments()

    if(ARTIFACTS_DIR)
        file(RELATIVE_PATH path ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
        file(MAKE_DIRECTORY ${ARTIFACTS_DIR}/${path})
        set(file_logger -o ${ARTIFACTS_DIR}/${path}/test${COMPONENT_NAME}.xml,xunitxml)
    else()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
        set(file_logger -o ${CMAKE_CURRENT_BINARY_DIR}/test${COMPONENT_NAME}.xml,xunitxml)
    endif()

    bake_arguments("${QMLTEST_ARG_PREFIX}" args ${iterations} ${file_logger} ${STDOUT_LOGGER})

    set(qmltest_command
        $<TARGET_FILE:${TARGET}>
            ${QMLTEST_ARGS}
            ${args}
    )

    add_qmltest_target(test${COMPONENT_NAME} ${TARGET}
        COMMAND ${qmltest_command}
        ${depends}
        ENVIRONMENT QML2_IMPORT_PATH=${imports} ${QMLTEST_ENVIRONMENT}
        ${add_test}
        ${targets}
    )

    if(TARGET xvfb-run)
        add_qmltest_target(xvfbtest${COMPONENT_NAME} ${TARGET}
            COMMAND $<TARGET_FILE:xvfb-run> --server-args "-screen 0 1024x768x24" --auto-servernum ${qmltest_command}
            ${depends}
            ENVIRONMENT QML2_IMPORT_PATH=${imports} ${QMLTEST_ENVIRONMENT} LD_PRELOAD=/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/mesa/libGL.so.1
            TARGETS ${xvfb_targets}
        )
    endif()

    if(TARGET gdb)
        add_qmltest_target(gdbtest${COMPONENT_NAME} ${TARGET}
            COMMAND $<TARGET_FILE:gdb> -ex run -args ${qmltest_command}
            ${depends}
            ENVIRONMENT QML2_IMPORT_PATH=${imports} ${QMLTEST_ENVIRONMENT}
        )
    endif()
endfunction()


# add_manual_test(target component_name
#     [DEPENDS target1 [target2 [...]]]                # make this test depend on the specified targets
#     [IMPORT_PATHS import_path1 [import_path2 [...]]  # use these QML import paths
#                                                      # (they're searched first to last)
#     [ENVIRONMENT var1=value1 [var2=value2 [...]]]    # set these environment variables
# )
#
# Two targets will be created:
#   - try${component_name} - Runs the test for manual interaction
#   - gdbtry${component_name} - Runs the test under gdb

function(add_manual_test COMPONENT_NAME TARGET)
    import_executables(gdb OPTIONAL)

    cmake_parse_arguments(QMLTEST "${QMLTEST_OPTIONS}" "${QMLTEST_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    mangle_arguments()

    bake_arguments("${QMLTEST_ARG_PREFIX}" args -qmljsdebugger=port:3768,3800)

    set(qmltry_command
        $<TARGET_FILE:${TARGET}>
            ${QMLTEST_ARGS}
            ${args}
    )

    add_qmltest_target(try${COMPONENT_NAME} ${TARGET}
        COMMAND ${qmltry_command}
        ${depends}
        ENVIRONMENT QML2_IMPORT_PATH=${imports} ${QMLTEST_ENVIRONMENT}
    )

    if(TARGET gdb)
        add_qmltest_target(gdbtry${COMPONENT_NAME} ${TARGET}
            COMMAND $<TARGET_FILE:gdb> -ex run -args ${qmltry_command}
            ${depends}
            ENVIRONMENT QML2_IMPORT_PATH=${imports} ${QMLTEST_ENVIRONMENT}
        )
    endif()
endfunction()


################### INTERNAL ####################

# add_qmltest_target(target_name target
#    COMMAND test_exe [arg1 [...]]       # execute this test with arguments
#    [...]                               # see above for available arguments:
#                                        # ADD_TEST, ENVIRONMENT, DEPENDS and TARGETS
# )

function(add_qmltest_target TARGET_NAME TARGET)
    cmake_parse_arguments(QMLTEST "${QMLTEST_OPTIONS}" "${QMLTEST_SINGLE}" "COMMAND;${QMLTEST_MULTI}" ${ARGN})
    mangle_arguments()

    # Additional arguments
    string(TOLOWER "${CMAKE_GENERATOR}" cmake_generator_lower)
    if(cmake_generator_lower STREQUAL "unix makefiles")
        set(function "$(FUNCTION)")
    endif()

    add_custom_target(${TARGET_NAME}
        env ${QMLTEST_ENVIRONMENT}
        ${QMLTEST_COMMAND} ${function}
        DEPENDS ${TARGET} ${QMLTEST_DEPENDS}
    )

    if(QMLTEST_ADD_TEST)
        add_test(
            NAME ${TARGET_NAME}
            COMMAND ${QMLTEST_COMMAND}
        )

        foreach(ENV ${QMLTEST_ENVIRONMENT})
            set_property(TEST ${TARGET_NAME} APPEND PROPERTY ENVIRONMENT ${ENV})
        endforeach()

        set_property(TEST ${TARGET_NAME} APPEND PROPERTY DEPENDS ${TARGET})
        foreach(DEPEND ${DEPENDS})
            set_property(TEST ${TARGET_NAME} APPEND PROPERTY DEPENDS ${DEPEND})
        endforeach()
    endif()

    foreach(UPSTREAM_TARGET ${QMLTEST_TARGETS})
        add_dependencies(${UPSTREAM_TARGET} ${TARGET_NAME})
    endforeach()
endfunction()


# mangle_arguments(${ARGN})
#
# Verify there were no unparsed arguments and
# mangle the known ones for further processing.

macro(mangle_arguments)
    if(QMLTEST_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unexpected arguments: ${QMLTEST_UNPARSED_ARGUMENTS}")
    endif()

    if(QMLTEST_ADD_TEST)
        set(add_test ADD_TEST)
    endif()

    if(QMLTEST_IMPORT_PATHS)
        string(REPLACE ";" ":" imports "${QMLTEST_IMPORT_PATHS}")
    endif()

    if(QMLTEST_ITERATIONS)
        set(iterations -iterations ${QMLTEST_ITERATIONS})
    endif()

    if(QMLTEST_DEPENDS)
        set(depends DEPENDS ${QMLTEST_DEPENDS})
    endif()

    if(QMLTEST_TARGETS)
        set(targets TARGETS ${QMLTEST_TARGETS})
    endif()

    set(xvfb_targets "")
    foreach(target ${QMLTEST_TARGETS})
        if(TARGET xvfb${target})
            list(APPEND xvfb_targets xvfb${target})
        endif()
    endforeach()
    set(xvfb_targets "${xvfb_targets}" PARENT_SCOPE)
endmacro()


# bake_arguments(prefix output
#    arg1 [arg2 [...]]
# )
#
# If set, add the argument prefix before every passed
# argument and store the result in ${OUTPUT} variable.

function(bake_arguments PREFIX OUTPUT)
    set(args "${ARGN}")
    if(PREFIX)
        set(args "")
        foreach(arg ${ARGN})
            list(APPEND args ${PREFIX})
            list(APPEND args ${arg})
        endforeach()
    endif()
    set(${OUTPUT} "${args}" PARENT_SCOPE)
endfunction()
