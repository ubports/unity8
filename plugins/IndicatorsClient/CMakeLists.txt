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


add_subdirectory(indicators)

if(NETWORK_PLUGIN_ENABLED)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DNETWORK_PLUGIN_ENABLED" )
endif()

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${QMENUMODEL_INCLUDE_DIRS}
    ${indicatorclient_common_SOURCE_DIR}
)

set(IndicatorsClientQML_SOURCES
    flatmenuproxymodel.cpp
    indicatorsfactory.cpp
    indicatorsmanager.cpp
    indicatorsmodel.cpp
    plugin.cpp
    widgetsmap.cpp
)

set(IndicatorsClientQML_QML
    qml/BasicMenu.qml
    qml/ButtonMenu.qml
    qml/DBusActionState.qml
    qml/DivMenu.qml
    qml/FactoryMenu.qml
    qml/HLine.qml
    qml/Menu.qml
    qml/PluginItem.qml
    qml/RemoveBackground.qml
    qml/SectionMenu.qml
    qml/SliderMenu.qml
    qml/SwitchMenu.qml
    qml/TextMenu.qml
    qml/ProgressMenu.qml
)

set(IndicatorsClientQM_RESOURCES
    indicatorsclient.qrc
)

add_library(IndicatorsClientQml MODULE
    ${IndicatorsClientQML_RCC}
    ${IndicatorsClientQML_SOURCES}
)

target_link_libraries(IndicatorsClientQml
    ${Qt5Core_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${GOBJECT_LDFLAGS}
    ${QMENUMODEL_LDFLAGS}
    indicatorclient_datetime
    indicatorclient_messaging
    indicatorclient_power
    indicatorclient_sound
    indicatorclient_network
)

qt5_use_modules(IndicatorsClientQml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
)

# copy qmldir file into build directory for shadow builds
file(COPY ${IndicatorsClientQML_QML}
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/qml
    )

install(TARGETS IndicatorsClientQml
        DESTINATION ${SHELL_APP_DIR}/plugins/IndicatorsClient
)

install(FILES qmldir
        DESTINATION ${SHELL_APP_DIR}/plugins/IndicatorsClient
)

install(FILES ${IndicatorsClientQML_QML}
        DESTINATION ${SHELL_APP_DIR}/plugins/IndicatorsClient/qml
)
