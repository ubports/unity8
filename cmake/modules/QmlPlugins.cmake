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
        ${QMLFILES_SEARCH_PATH}/qmldir
    )

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
endmacro(export_qmlfiles)


# Creates a target for generating the typeinfo file for a QML plugin and optionally installs it
# and additional targets.
#
# Files will be copied into ${BINARY_DIR}/${path} or ${CMAKE_CURRENT_BINARY_DIR} and installed
# into ${DESTINATION}/${path}. If you don't pass BINARY_DIR, it's  assumed that current source
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
# )
#
# Created target:
#   - ${TARGET_PREFIX}${plugin}-qmltypes - Generates the qmltypes file in the binary dir.

macro(export_qmlplugin PLUGIN VERSION PATH)
    set(single BINARY_DIR DESTINATION TARGET_PREFIX ENVIRONMENT)
    set(multi TARGETS)
    cmake_parse_arguments(QMLPLUGIN "" "${single}" "${multi}" ${ARGN})

    get_target_property(qmlplugindump_executable qmlplugindump LOCATION)

    if(QMLPLUGIN_BINARY_DIR)
        set(qmlplugin_dir ${QMLPLUGIN_BINARY_DIR}/${PATH})
    else()
        # Find import path to point qmlplugindump at
        string(REGEX REPLACE "${PATH}$" "" QMLPLUGIN_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")
        set(qmlplugin_dir ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    # Find the last segment of the plugin name to use as qmltypes basename
    string(REGEX MATCH "[^.]+$" plugin_suffix ${PLUGIN})
    set(target_prefix ${QMLPLUGIN_TARGET_PREFIX}${PLUGIN})
    set(qmltypes_path ${qmlplugin_dir}/${plugin_suffix}.qmltypes)

    # Only generate typeinfo if not cross compiling
    if(NOT CMAKE_CROSSCOMPILING)
        add_custom_target(${target_prefix}-qmltypes ALL
            COMMAND env ${QMLPLUGIN_ENVIRONMENT} ${qmlplugindump_executable} -notrelocatable
                    ${PLUGIN} ${VERSION} ${QMLPLUGIN_BINARY_DIR} > ${qmltypes_path}
        )
        add_dependencies(${target_prefix}-qmltypes ${target_prefix}-qmlfiles ${QMLPLUGIN_TARGETS})

        if (QMLPLUGIN_DESTINATION)
            # Install the typeinfo file
            install(FILES ${qmltypes_path}
                    DESTINATION ${QMLPLUGIN_DESTINATION}/${PATH}
            )
        endif()
    endif()

    if (QMLPLUGIN_DESTINATION)
        # Install additional targets
        install(TARGETS ${QMLPLUGIN_TARGETS}
                DESTINATION ${QMLPLUGIN_DESTINATION}/${PATH}
        )
    endif()
endmacro()
