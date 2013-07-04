find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)
pkg_search_module(DEE dee-1.0 REQUIRED)
pkg_search_module(GOBJECT gobject-2.0 REQUIRED)
pkg_search_module(HUDCLIENT hud-client-2 REQUIRED)
pkg_search_module(DEEQT libdee-qt5 REQUIRED)
pkg_search_module(PULSE libpulse REQUIRED)

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
  ${DEE_INCLUDE_DIRS}
  ${DEEQT_INCLUDE_DIRS}
  ${HUDCLIENT_INCLUDE_DIRS}
  ${PULSE_INCLUDE_DIRS}
)

set(HudQML_SOURCES
  hudclient.cpp
  hudtoolbarmodel.cpp
  volumepeakdetector.cpp
  plugin.cpp
)

add_library(HudClientQml MODULE ${HudQML_SOURCES})
target_link_libraries(HudClientQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
  ${DEEQT_LDFLAGS}
  ${HUDCLIENT_LDFLAGS}
  ${GOBJECT_LDFLAGS}
  ${PULSE_LDFLAGS}
)

qt5_use_modules(HudClientQml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS HudClientQml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/HudClient
    )

install(FILES qmldir
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/HudClient
    )
