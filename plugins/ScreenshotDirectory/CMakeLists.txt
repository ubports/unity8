set(PLUGIN_SOURCES
  ScreenshotDirectory.cpp
  plugin.cpp
)

add_library(ScreenshotDirectory-qml MODULE ${PLUGIN_SOURCES})
target_link_libraries(ScreenshotDirectory-qml Qt5::Qml Qt5::Gui Qt5::Quick)

add_lomiri_plugin(ScreenshotDirectory 0.1 ScreenshotDirectory TARGETS ScreenshotDirectory-qml)
