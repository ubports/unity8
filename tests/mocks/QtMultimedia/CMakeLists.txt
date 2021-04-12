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

target_link_libraries(QtMultimedia-qml Qt5::Qml Qt5::Quick)

add_lomiri_mock(QtMultimedia 5.0 QtMultimedia TARGETS QtMultimedia-qml)
