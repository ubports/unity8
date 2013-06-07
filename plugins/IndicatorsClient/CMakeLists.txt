project(IndicatorsClientQml)

pkg_check_modules(GLIB glib-2.0>=2.32)
pkg_check_modules(LIBNM_GLIB libnm-glib>=0.9.6)
pkg_check_modules(LIBNM_UTIL libnm-util>=0.9.6)
pkg_check_modules(QMENUMODEL REQUIRED qmenumodel)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

if(LIBNM_GLIB_FOUND AND LIBNM_UTIL_FOUND AND GLIB_FOUND)
    set(NETWORK_PLUGIN_ENABLED 1)
else()
    set(NETWORK_PLUGIN_ENABLED 0)
    message(WARNING "Missing glib or libnm dependency for the network plugin, not building")
endif()

add_subdirectory(qml)

if(NETWORK_PLUGIN_ENABLED)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DNETWORK_PLUGIN_ENABLED" )

    add_subdirectory(Network)
endif()

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${QMENUMODEL_INCLUDE_DIRS}
)

set(IndicatorsClientQML_SOURCES
    flatmenuproxymodel.cpp
    indicator.cpp
    indicatorsmanager.cpp
    indicatorsmodel.cpp
    plugin.cpp
)

set(IndicatorsClientQML_RESOURCES
    resources/indicatorclient.qrc
)

qt5_add_resources(IndicatorsClientQML_RESOURCES_RCC
    ${IndicatorsClientQML_RESOURCES}
)

add_library(IndicatorsClientQml SHARED
    ${IndicatorsClientQML_RESOURCES_RCC}
    ${IndicatorsClientQML_SOURCES}
)
# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(IndicatorsClientQml PROPERTIES COMPILE_FLAGS -fvisibility=default)

target_link_libraries(IndicatorsClientQml
    ${Qt5Core_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${GOBJECT_LDFLAGS}
    ${QMENUMODEL_LDFLAGS}
)

qt5_use_modules(IndicatorsClientQml Qml)
