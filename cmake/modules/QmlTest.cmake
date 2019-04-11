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


# add_qml_test_data(path component_name
#     [...]
# )
#
# Install file called ${component_name} (or ${component_name}.qml) under
# ${path}.

function(add_qml_test_data PATH COMPONENT_NAME)
    cmake_parse_arguments(TEST "" "DESTINATION" "" ${ARGN})

    set(filename "${CMAKE_CURRENT_SOURCE_DIR}/${PATH}/${COMPONENT_NAME}")

    if (IS_DIRECTORY "${filename}")
        # As a convenience, allow specifying a directory and we will install
        # all files in the dir.  We do it this way rather than passing
        # DIRECTORY to install() because we want to process any qml files.
        file(GLOB subfiles RELATIVE "${filename}" "${filename}/*")
        foreach(subfile ${subfiles})
            add_qml_test_data("${PATH}/${COMPONENT_NAME}" "${subfile}")
        endforeach()
        return()
    endif()

    if (NOT EXISTS "${filename}")
        set(filename "${filename}.qml")
        set(COMPONENT_NAME "${COMPONENT_NAME}.qml")
    endif()

    if ("${filename}" MATCHES "\\.qml$")
        file(READ "${filename}" contents)
        string(REGEX REPLACE "(\"[./]*)/qml(/|\")" "\\1\\2" contents "${contents}")
        # this is for (at least) cardcreatortest which pulls in an architecture-specific
        # import into the plugins directory (which is a 'qml' once installed).
        string(REGEX REPLACE "(import \"[./]*)/plugins(/|\")" "\\1/qml\\2" contents "${contents}")
        set(filename "${CMAKE_CURRENT_BINARY_DIR}/${PATH}/${COMPONENT_NAME}")
        file(WRITE "${filename}" "${contents}")
    endif()

    if (TEST_DESTINATION)
        set(DESTINATION "${TEST_DESTINATION}")
    else()
        file(RELATIVE_PATH relcurpath "${CMAKE_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
        set(DESTINATION "${SHELL_APP_DIR}/${relcurpath}/${PATH}")
    endif()

    install(FILES "${filename}" DESTINATION "${DESTINATION}")
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

    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${PATH}/tst_${COMPONENT_NAME}.qml")
        add_qml_test_data("${PATH}" "tst_${COMPONENT_NAME}.qml")
    endif()
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

    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${PATH}/tst_${COMPONENT_NAME}.qml")
        add_qml_test_data("${PATH}" "tst_${COMPONENT_NAME}.qml")
    endif()
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
# XUnitXML files will be stored in current binary dir.
#
# Three targets will be created:
#   - test${component_name} - Runs the test
#   - xvfbtest${component_name} - Runs the test under xvfb
#   - gdbtest${component_name} - Runs the test under gdb

function(add_executable_test COMPONENT_NAME TARGET)
    import_executables(gdb xvfb-run OPTIONAL)

    cmake_parse_arguments(QMLTEST "${QMLTEST_OPTIONS}" "${QMLTEST_SINGLE}" "${QMLTEST_MULTI}" ${ARGN})
    mangle_arguments()

    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    set(file_logger -o ${CMAKE_CURRENT_BINARY_DIR}/test${COMPONENT_NAME}.xml,xunitxml)

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
            ENVIRONMENT QT_QPA_PLATFORM=xcb QML2_IMPORT_PATH=${imports} LD_PRELOAD=/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/mesa/libGL.so.1 ${QMLTEST_ENVIRONMENT}
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


# add_meta_test(target)
#
# Adds a test target that will run one of our "meta" test targets, like
# xvfbuitests.  This script will run the specified suite of tests on an
# installed system.

function(add_meta_test TARGET_NAME)
    cmake_parse_arguments(TEST "SERIAL" "" "DEPENDS" ${ARGN})

    add_custom_target(${TARGET_NAME})

    set(filename "${CMAKE_BINARY_DIR}/tests/scripts/${TARGET_NAME}.sh")
    if(TEST_SERIAL)
        file(WRITE "${filename}" "#!/bin/sh\n\n")
    else()
        file(WRITE "${filename}" "#!/usr/bin/parallel --shebang --no-notice\n\n")
    endif()

    add_meta_dependencies(${TARGET_NAME} DEPENDS ${TEST_DEPENDS})
    # else we will write the rest of the script as we add cmake targets

    install(FILES "${filename}"
        PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE
                    GROUP_EXECUTE GROUP_READ
                    WORLD_EXECUTE WORLD_READ
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/scripts"
    )
endfunction()


################### INTERNAL ####################

function(install_test_script TARGET_NAME)
    cmake_parse_arguments(TEST "" "" "COMMAND;ENVIRONMENT" ${ARGN})

    # Now write the above test into a shell script that we can run on an
    # installed system.
    set(script "#!/bin/sh\n\nset -x\n\n")
    foreach(ONE_ENV ${TEST_ENVIRONMENT})
        set(script "${script}export ${ONE_ENV}\n")
    endforeach()
    set(script "${script}export UNITY_TESTING_DATADIR=\"${CMAKE_INSTALL_PREFIX}/${SHELL_APP_DIR}\"\n")
    set(script "${script}export UNITY_TESTING_LIBDIR=\"${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}\"\n")
    set(script "${script}\n")
    set(script "${script}XML_ARGS=\n")
    set(script "${script}if [ -n \"\$ARTIFACTS_DIR\" ]; then\n")
    set(script "${script}    XML_ARGS=\"@XML_ARGS@\"\n")
    set(script "${script}    mkdir -p \"@XML_DIR@\"\n")
    set(script "${script}    touch \"@XML_FILE@\"\n")
    set(script "${script}fi\n")
    set(script "${script}\n")
    foreach(ONE_CMD ${TEST_COMMAND})
        set(script "${script}'${ONE_CMD}' ")
    endforeach()
    set(script "${script}\"\$@\"") # Allow passing arguments if desired

    set(filename "${CMAKE_BINARY_DIR}/tests/scripts/${TARGET_NAME}.sh")

    # Generate script to file then read it back to resolve any generator
    # expressions before we try to replace paths.
    file(GENERATE
         OUTPUT "${filename}"
         CONTENT "${script}"
    )

    # Do replacement at install time to save needless work and to make sure
    # we are modifying file after generate step above (which doesn't happen
    # immediately).  We can't use a custom-defined function or macro here...
    # So instead we use a giant ugly code block.

    # START OF CODE BLOCK --------------------------------------------------
    install(CODE "
    file(READ \"${filename}\" replacestr)

    # Now some replacements...
    # tests like to write xml output to our builddir; we don't need that, but we do want them in ARTIFACTS_DIR
    string(REGEX MATCH \"( '--parameter')? '-o'( '--parameter')? '[^']*,xunitxml' \" xmlargs \"\${replacestr}\")
    string(REGEX REPLACE \"( '--parameter')? '-o'( '--parameter')? '[^']*,xunitxml' \" \" \\\$XML_ARGS \" replacestr \"\${replacestr}\")
    string(REGEX REPLACE \"'[^']*/tests/\" \"'\\\$ARTIFACTS_DIR/tests/\" xmlargs \"\${xmlargs}\")
    string(REGEX REPLACE \".*'([^']*),xunitxml'.*\" \"\\\\1\" xmlfile \"\${xmlargs}\")
    string(REGEX REPLACE \"(.*)/[^/]*\" \"\\\\1\" xmldir \"\${xmlfile}\")
    string(REGEX REPLACE \"'\" \"\" xmlargs \"\${xmlargs}\") # strip single quotes
    string(REGEX REPLACE \"@XML_ARGS@\" \"\${xmlargs}\" replacestr \"\${replacestr}\")
    string(REGEX REPLACE \"@XML_DIR@\" \"\${xmldir}\" replacestr \"\${replacestr}\")
    string(REGEX REPLACE \"@XML_FILE@\" \"\${xmlfile}\" replacestr \"\${replacestr}\")
    # replace build/source roots with their install paths
    string(REPLACE \"${CMAKE_BINARY_DIR}/libs\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_BINARY_DIR}/plugins\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_BINARY_DIR}/tests/libs\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}/tests/libs\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_BINARY_DIR}/tests/mocks\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/mocks\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_BINARY_DIR}/tests/plugins\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}/tests/plugins\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_BINARY_DIR}/tests/qmltests\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}/tests/qmltests\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_BINARY_DIR}/tests/uqmlscene\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_BINARY_DIR}/tests/utils/modules\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/utils\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_SOURCE_DIR}/tests/plugins\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_APP_DIR}/tests/plugins\" replacestr \"\${replacestr}\")
    string(REPLACE \"${CMAKE_SOURCE_DIR}/tests/qmltests\" \"${CMAKE_INSTALL_PREFIX}/${SHELL_APP_DIR}/tests/qmltests\" replacestr \"\${replacestr}\")

    file(WRITE \"${filename}\" \"\${replacestr}\")
    ")
    # END OF CODE BLOCK --------------------------------------------------

    install(FILES "${filename}"
        PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE
                    GROUP_EXECUTE GROUP_READ
                    WORLD_EXECUTE WORLD_READ
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/scripts"
    )
endfunction()

function(add_meta_dependencies UPSTREAM_TARGET)
    cmake_parse_arguments(TEST "" "" "DEPENDS" ${ARGN})

    foreach(depend ${TEST_DEPENDS})
        add_dependencies(${UPSTREAM_TARGET} ${depend})

        # add depend to the meta test script that we will install on system
        set(filename "${CMAKE_BINARY_DIR}/tests/scripts/${UPSTREAM_TARGET}.sh")
        if (EXISTS "${filename}")
            file(APPEND "${filename}" "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}/tests/scripts/${depend}.sh \"\$@\" 2>&1\n")
        endif()
    endforeach()
endfunction()

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

    install_test_script(${TARGET_NAME}
        ENVIRONMENT ${QMLTEST_ENVIRONMENT}
        COMMAND ${QMLTEST_COMMAND}
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
        add_meta_dependencies(${UPSTREAM_TARGET} DEPENDS ${TARGET_NAME})
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
