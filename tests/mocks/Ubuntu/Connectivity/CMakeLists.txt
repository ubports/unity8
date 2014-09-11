add_library(connectivity-qml SHARED
    networking-status.cpp
    plugin.cpp
)
qt5_use_modules(connectivity-qml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )
