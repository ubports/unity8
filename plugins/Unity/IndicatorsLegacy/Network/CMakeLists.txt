# export_qmlplugin macro
include(Plugins)

project(IndicatorsLegacyNetworkQml)

pkg_check_modules(GLIB glib-2.0>=2.32)
pkg_check_modules(LIBNM_GLIB libnm-glib>=0.9.6)
pkg_check_modules(LIBNM_UTIL libnm-util>=0.9.6)

if(LIBNM_GLIB_FOUND AND LIBNM_UTIL_FOUND AND GLIB_FOUND)
    set(INDICATORS_LEGACY_NETWORK_SRC
        networkagent.cpp
        plugin.cpp
        secret-agent.c
    )

    add_library(IndicatorsLegacyNetworkQml MODULE
        ${INDICATORS_LEGACY_NETWORK_SRC}
    )

    qt5_use_modules(IndicatorsLegacyNetworkQml Core Qml Widgets)

    set_target_properties(IndicatorsLegacyNetworkQml PROPERTIES COMPILE_FLAGS -fPIC)

    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${GLIB_INCLUDE_DIRS}
        ${LIBNM_GLIB_INCLUDE_DIRS}
        ${LIBNM_UTIL_INCLUDE_DIRS}
    )

    target_link_libraries(IndicatorsLegacyNetworkQml
        ${GLIB_LIBRARIES}
        ${LIBNM_GLIB_LIBRARIES}
        ${LIBNM_UTIL_LIBRARIES}
    )

    # export the qmltypes and plugin files
    export_qmlplugin(Unity.IndicatorsLegacy.Network 0.1 Unity/IndicatorsLegacy/Network TARGETS IndicatorsLegacyNetworkQml)

else()
    message(WARNING "Missing glib or libnm dependency for the network plugin, not building")
endif()

add_subdirectory(qml)
