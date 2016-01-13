add_library(QtMultimedia-qml MODULE
    plugin.cpp
    audio.cpp
    declarativeplaylist.cpp
    )

qt5_use_modules(QtMultimedia-qml Qml)

add_unity8_mock(QtMultimedia 5.0 QtMultimedia TARGETS QtMultimedia-qml)
