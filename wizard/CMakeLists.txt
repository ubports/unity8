# This file uses a lot of namespacing like "ubuntu-system-settings" instead of
# "unity8".  This is because we have imported it from ubuntu-system-settings
# and haven't fully integrated it yet.

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(PLUGIN_MANIFEST_DIR_BASE share/ubuntu/settings/system)
set(PLUGIN_MODULE_DIR_BASE ubuntu-system-settings)
set(PLUGIN_PRIVATE_MODULE_DIR_BASE "${PLUGIN_MODULE_DIR_BASE}/private")
set(PLUGIN_QML_DIR_BASE share/ubuntu/settings/system/qml-plugins)

set(PLUGIN_MANIFEST_DIR "${CMAKE_INSTALL_PREFIX}/${PLUGIN_MANIFEST_DIR_BASE}")
set(PLUGIN_MODULE_DIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${PLUGIN_MODULE_DIR_BASE}")
set(PLUGIN_PRIVATE_MODULE_DIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${PLUGIN_PRIVATE_MODULE_DIR_BASE}")
set(PLUGIN_QML_DIR "${CMAKE_INSTALL_PREFIX}/${PLUGIN_QML_DIR_BASE}")

add_definitions(-DI18N_DOMAIN="unity8")
add_definitions(-DPLUGIN_MANIFEST_DIR="${PLUGIN_MANIFEST_DIR}")
add_definitions(-DPLUGIN_MODULE_DIR="${PLUGIN_MODULE_DIR}")
add_definitions(-DPLUGIN_PRIVATE_MODULE_DIR="${PLUGIN_PRIVATE_MODULE_DIR}")
add_definitions(-DPLUGIN_QML_DIR="${PLUGIN_QML_DIR}")

execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=plugindir unity-shell-api OUTPUT_VARIABLE SHELL_PLUGINDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
if(SHELL_PLUGINDIR STREQUAL "")
    message(FATAL_ERROR "Could not determine plugin import dir.")
endif()

add_definitions(-DSHELL_PLUGINDIR="${SHELL_PLUGINDIR}")

set(WIZARD_ROOT "${CMAKE_INSTALL_PREFIX}/share")
add_definitions(-DWIZARD_ROOT="${WIZARD_ROOT}")

file(GLOB_RECURSE QML_FILES
    qml/*
)

set(WIZARD_SOURCES
    main.cpp
    PageList.cpp
)

add_executable(system-settings-wizard
    ${WIZARD_SOURCES}
    ${system-settings-wizard-resources}
    ${QML_FILES} # This is to make qml and image files appear in the IDE's project tree
)

qt5_use_modules(system-settings-wizard Core Gui Quick Qml)

add_subdirectory(Unity)
add_subdirectory(Utils)

install(TARGETS system-settings-wizard RUNTIME DESTINATION bin)
install(FILES ubuntu-system-settings-wizard.conf
              ubuntu-system-settings-wizard-cleanup.conf
              ubuntu-system-settings-wizard-set-lang.conf
        DESTINATION share/upstart/sessions)

set(POLKIT_LIB_DIR "${CMAKE_INSTALL_LOCALSTATEDIR}/lib/polkit-1")
install(FILES 50-com.ubuntu.system-settings.wizard.pkla DESTINATION ${POLKIT_LIB_DIR}/localauthority/10-vendor.d)

install(DIRECTORY qml DESTINATION ${WIZARD_ROOT}/ubuntu/settings/wizard)
