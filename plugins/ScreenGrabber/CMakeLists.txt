include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
)

set(SCREENGRABBERSOURCES
  screengrabber.cpp
  plugin.cpp
)

add_library(ScreenGrabber-qml MODULE ${SCREENGRABBERSOURCES})
qt5_use_modules(ScreenGrabber-qml Qml Gui Quick Concurrent)

add_unity8_plugin(ScreenGrabber 0.1 ScreenGrabber TARGETS ScreenGrabber-qml)
