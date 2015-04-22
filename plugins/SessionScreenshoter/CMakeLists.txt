include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
)

set(SOURCES
  sessionscreenshoter.cpp
  plugin.cpp
)

add_library(SessionScreenshoter-qml MODULE ${SOURCES})
qt5_use_modules(SessionScreenshoter-qml Qml Gui Quick Concurrent)

add_unity8_plugin(SessionScreenshoter 0.1 SessionScreenshoter TARGETS SessionScreenshoter-qml)
