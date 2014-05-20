include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
)

set(GSettingsQML_SOURCES
  fake_gsettings.cpp
  plugin.cpp
)

add_library(FakeGSettingsQml MODULE ${GSettingsQML_SOURCES})
target_link_libraries(FakeGSettingsQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
)

qt5_use_modules(FakeGSettingsQml Qml)

add_unity8_mock(GSettings 1.0 GSettings.1.0 TARGETS FakeGSettingsQml)
