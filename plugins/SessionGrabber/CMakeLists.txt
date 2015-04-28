include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
)

add_library(SessionGrabber-qml MODULE sessiongrabber.cpp plugin.cpp)
qt5_use_modules(SessionGrabber-qml Qml Gui Quick Concurrent)

add_unity8_plugin(SessionGrabber 0.1 SessionGrabber TARGETS SessionGrabber-qml)
