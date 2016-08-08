include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

add_library(QtMultimedia-qml MODULE
    plugin.cpp
    mediaplayer.cpp
    videooutput.cpp
    declarativeplaylist.cpp
    )

qt5_use_modules(QtMultimedia-qml Qml Quick)

add_unity8_mock(QtMultimedia 5.0 QtMultimedia TARGETS QtMultimedia-qml)
