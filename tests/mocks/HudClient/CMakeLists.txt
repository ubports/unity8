pkg_search_module(DEE dee-1.0 REQUIRED)
pkg_search_module(GOBJECT gobject-2.0 REQUIRED)
pkg_search_module(HUDCLIENT hud-client-2 REQUIRED)
pkg_search_module(DEEQT libdee-qt5 REQUIRED)
pkg_search_module(PULSE libpulse REQUIRED)

include_directories(
  ${CMAKE_SOURCE_DIR}/plugins/HudClient
  ${CMAKE_CURRENT_BINARY_DIR}
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
  ${DEE_INCLUDE_DIRS}
  ${DEEQT_INCLUDE_DIRS}
  ${HUDCLIENT_INCLUDE_DIRS}
  ${PULSE_INCLUDE_DIRS}
)

set(HudQML_SOURCES
  ${CMAKE_SOURCE_DIR}/plugins/HudClient/hudclient.cpp
  ${CMAKE_SOURCE_DIR}/plugins/HudClient/volumepeakdetector.cpp
  ${CMAKE_SOURCE_DIR}/plugins/HudClient/hudtoolbarmodel.cpp
  fake_hud_plugin.cpp
  fake_libhud_client.cpp
  libhud_client_stub.cpp
)

add_library(FakeHudClientQml MODULE ${HudQML_SOURCES})
target_link_libraries(FakeHudClientQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
  ${DEEQT_LDFLAGS}
  ${GOBJECT_LDFLAGS}
  ${PULSE_LDFLAGS}
)

qt5_use_modules(FakeHudClientQml Qml)

add_unity8_mock(HudClient 0.1 HudClient TARGETS FakeHudClientQml)
