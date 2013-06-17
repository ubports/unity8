project(IndicatorsNetworkQml)

set(INDICATORS_NETWORK_SRC
    networkagent.cpp
    plugin.cpp
    secret-agent.c
)

add_library(IndicatorsNetworkQml MODULE
    ${INDICATORS_NETWORK_SRC}
)

qt5_use_modules(IndicatorsNetworkQml Core Qml Widgets)

set_target_properties(IndicatorsNetworkQml PROPERTIES COMPILE_FLAGS -fPIC)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${GLIB_INCLUDE_DIRS}
    ${QMENUMODEL_INCLUDE_DIRS}
    ${LIBNM_GLIB_INCLUDE_DIRS}
    ${LIBNM_UTIL_INCLUDE_DIRS}
)

target_link_libraries(IndicatorsNetworkQml
    ${GLIB_LIBRARIES}
    ${QMENUMODEL_LDFLAGS}
    ${LIBNM_GLIB_LIBRARIES}
    ${LIBNM_UTIL_LIBRARIES}
)