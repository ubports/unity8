set(INDICATORCLIENT_NETWORK_SRC
    indicatorclient_network.cpp
    networkagent.cpp
    secret-agent.c
)

add_library(indicatorclient_network
    ${INDICATORCLIENT_NETWORK_SRC}
)

qt5_use_modules(indicatorclient_network Core Qml Widgets)

set_target_properties(indicatorclient_network PROPERTIES COMPILE_FLAGS -fPIC)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${GLIB_INCLUDE_DIRS}
    ${LIBNM_GLIB_INCLUDE_DIRS}
    ${LIBNM_UTIL_INCLUDE_DIRS}
    ${QMENUMODEL_INCLUDE_DIRS}
    ${indicatorclient_common_SOURCE_DIR}
    ${IndicatorsClientQml_SOURCE_DIR}
)

target_link_libraries(indicatorclient_network
    indicatorclient_common
    ${GLIB_LIBRARIES}
    ${LIBNM_GLIB_LIBRARIES}
    ${LIBNM_UTIL_LIBRARIES}
    ${QMENUMODEL_LDFLAGS}
)

set(INDICATOR_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-network.indicator
)

# copy indicators file into build directory for shadow builds
file(COPY ${INDICATOR_FILES}
    DESTINATION ${CMAKE_BINARY_DIR}/share/unity/indicators
)

# install indicator file
install(FILES ${INDICATOR_FILES}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/unity/indicators
)
