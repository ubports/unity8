add_library(ImageCache-qml MODULE
    ImageCache.cpp
    plugin.cpp
    )

qt5_use_modules(ImageCache-qml Gui Qml Quick)

add_unity8_plugin(ImageCache 0.1 ImageCache TARGETS ImageCache-qml)
