# There's no cmake var for v8 include path :-/
# so create one
LIST(GET Qt5Core_INCLUDE_DIRS 0 QtCoreDir0)
SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/../QtV8/${Qt5Core_VERSION_STRING}/QtV8)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${Qt5V8_PRIVATE_INCLUDE_DIR}
)

remove_definitions(-DQT_NO_KEYWORDS)

set(QMLPLUGIN_SRC
    plugin.cpp
    listviewwithpageheader.cpp
    )

add_library(ListViewWithPageHeader-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(ListViewWithPageHeader-qml
    ${Qt5Gui_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    )

qt5_use_modules(ListViewWithPageHeader-qml Qml Quick)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS ListViewWithPageHeader-qml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/ListViewWithPageHeader
    )

install(FILES qmldir
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/ListViewWithPageHeader
    )
