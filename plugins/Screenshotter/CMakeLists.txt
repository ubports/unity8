include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
)

set(SCREENSHOTTERSOURCES
  screenshotter.cpp
  plugin.cpp
)

add_library(Screenshotter-qml MODULE ${SCREENSHOTTERSOURCES})
qt5_use_modules(Screenshotter-qml Qml Gui Quick)

add_unity8_plugin(Screenshotter 0.1 Screenshotter TARGETS Screenshotter-qml)
