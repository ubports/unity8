# If you need to override the qmlplugindump binary, create the qmlplugin executable
# target before loading this plugin.

if(NOT TARGET qmlplugindump)
    find_program(qmlplugindump_exe qmlplugindump)

    if(NOT qmlplugindump_exe)
      msg(FATAL_ERROR "Could not locate qmlplugindump.")
    endif()

    add_executable(qmlplugindump IMPORTED)
    set_target_properties(qmlplugindump PROPERTIES IMPORTED_LOCATION ${qmlplugindump_exe})
endif()

#
# A custom target for building the qmltypes files manually.
#
if (NOT TARGET qmltypes)
    add_custom_target(qmltypes)
endif()

# Creates a target for copying resource files into build dir and optionally installing them.
#
# Files will be copied into ${BINARY_DIR}/${path} or ${CMAKE_CURRENT_BINARY_DIR} and installed
# into ${DESTINATION}/${path}.
#
# Resource file names are matched against {*.{qml,js,jpg,png,sci,svg},qmldir}.
#
# export_qmlfiles(plugin path
#     [SEARCH_PATH path]      # Path to search for resources in (defaults to ${CMAKE_CURRENT_SOURCE_DIR})
#     [BINARY_DIR path]
#     [DESTINATION path]
#     [TARGET_PREFIX string]  # Will be prefixed to the target name
# )
#
# Created target:
#   - ${TARGET_PREFIX}${plugin}-qmlfiles - Copies resources into the binary dir.

macro(export_qmlfiles PLUGIN PATH)
    set(single SEARCH_PATH BINARY_DIR DESTINATION TARGET_PREFIX)
    cmake_parse_arguments(QMLFILES "" "${single}" "" ${ARGN})
 
    if(NOT QMLFILES_SEARCH_PATH)
        set(QMLFILES_SEARCH_PATH ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    if(QMLFILES_BINARY_DIR)
        set(qmlfiles_dir ${QMLFILES_BINARY_DIR}/${PATH})
    else()
        set(qmlfiles_dir ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    file(GLOB QMLFILES
        ${QMLFILES_SEARCH_PATH}/*.qml
        ${QMLFILES_SEARCH_PATH}/*.js
        ${QMLFILES_SEARCH_PATH}/*.jpg
        ${QMLFILES_SEARCH_PATH}/*.png
        ${QMLFILES_SEARCH_PATH}/*.sci
        ${QMLFILES_SEARCH_PATH}/*.svg
        ${QMLFILES_SEARCH_PATH}/*.qmltypes
        ${QMLFILES_SEARCH_PATH}/qmldir
    )

    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${qmlfiles_dir})

    # copy the files
    add_custom_target(${QMLFILES_TARGET_PREFIX}${PLUGIN}-qmlfiles ALL
                        COMMAND cp ${QMLFILES} ${qmlfiles_dir}
                        DEPENDS ${QMLFILES}
                        SOURCES ${QMLFILES}
    )

    if(QMLFILES_DESTINATION)
        # install the qmlfiles file.
        install(FILES ${QMLFILES}
            DESTINATION ${QMLFILES_DESTINATION}/${PATH}
        )
    endif()
endmacro()


# Creates a target for generating the typeinfo file for a QML plugin and/or installs the plugin
# targets.
#
# Files will be copied into ${BINARY_DIR}/${path} or ${CMAKE_CURRENT_BINARY_DIR} and installed
# into ${DESTINATION}/${path}. If you don't pass BINARY_DIR, it's assumed that current source
# path ends with ${path}.
#
# The generated file will be named after the last segment of the plugin name, e.g. Foo.qmltypes.
#
# export_qmlplugin(plugin version path
#     [BINARY_DIR path]
#     [DESTINATION path]
#     [TARGET_PREFIX string]  # Will be prefixed to the target name
#     [ENVIRONMENT string]    # Will be added to qmlplugindump's env
#     [TARGETS target1 [target2 ...]] # Targets to depend on and install (e.g. the plugin shared object)
#     [NO_TYPES] # Do not create the qmltypes target
# )
#
# Created target:
#   - ${TARGET_PREFIX}${plugin}-qmltypes - Generates the qmltypes file in the source dir.
#     It will be made a dependency of the "qmltypes" target.

macro(export_qmlplugin PLUGIN VERSION PATH)
    set(options NO_TYPES)
    set(single BINARY_DIR DESTINATION TARGET_PREFIX ENVIRONMENT)
    set(multi TARGETS)
    cmake_parse_arguments(QMLPLUGIN "${options}" "${single}" "${multi}" ${ARGN})

    if(QMLPLUGIN_BINARY_DIR)
        set(qmlplugin_dir ${QMLPLUGIN_BINARY_DIR}/${PATH})
    else()
        # Find import path to point qmlplugindump at
        string(REGEX REPLACE "/${PATH}$" "" QMLPLUGIN_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
        set(qmlplugin_dir ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    if(NOT QMLPLUGIN_NO_TYPES)
        # Relative path for the module
        string(REPLACE "${CMAKE_BINARY_DIR}/" "" QMLPLUGIN_MODULE_DIR "${QMLPLUGIN_BINARY_DIR}")

        # Find the last segment of the plugin name to use as qmltypes basename
        string(REGEX MATCH "[^.]+$" plugin_suffix ${PLUGIN})
        set(target_prefix ${QMLPLUGIN_TARGET_PREFIX}${PLUGIN})
        set(qmltypes_path ${CMAKE_CURRENT_SOURCE_DIR}/${plugin_suffix}.qmltypes)

        add_custom_target(${target_prefix}-qmltypes
            COMMAND env ${QMLPLUGIN_ENVIRONMENT} $<TARGET_FILE:qmlplugindump> -notrelocatable
                    ${PLUGIN} ${VERSION} ${QMLPLUGIN_MODULE_DIR} > ${qmltypes_path}
                    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )
        add_dependencies(${target_prefix}-qmltypes ${target_prefix}-qmlfiles ${QMLPLUGIN_TARGETS})
        add_dependencies(qmltypes ${target_prefix}-qmltypes)
    endif()

    set_target_properties(${QMLPLUGIN_TARGETS} PROPERTIES
                          ARCHIVE_OUTPUT_DIRECTORY ${qmlplugin_dir}
                          LIBRARY_OUTPUT_DIRECTORY ${qmlplugin_dir}
                          RUNTIME_OUTPUT_DIRECTORY ${qmlplugin_dir}
    )

    if (QMLPLUGIN_DESTINATION)
        # Install additional targets
        install(TARGETS ${QMLPLUGIN_TARGETS}
                DESTINATION ${QMLPLUGIN_DESTINATION}/${PATH}
        )
    endif()
endmacro()
