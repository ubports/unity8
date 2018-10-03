add_library(ImageCache-qml MODULE
    ImageCache.cpp
    plugin.cpp
    )

target_link_libraries(ImageCache-qml Qt5::Gui Qt5::Qml Qt5::Quick)

add_unity8_plugin(ImageCache 0.1 ImageCache TARGETS ImageCache-qml)
