set(PLUGIN_SOURCES
  ScreenshotDirectory.cpp
  plugin.cpp
)

add_library(ScreenshotDirectory-qml MODULE ${PLUGIN_SOURCES})
qt5_use_modules(ScreenshotDirectory-qml Qml Gui Quick)

add_unity8_plugin(ScreenshotDirectory 0.1 ScreenshotDirectory TARGETS ScreenshotDirectory-qml)
