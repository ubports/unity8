include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    )

include_directories(
    SYSTEM
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    )

add_definitions(-DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DTEST_DIR="plugins/ImageCache")
remove_definitions(-DQT_NO_KEYWORDS)

add_executable(ImageCacheTestExec
    test.cpp
    )
qt5_use_modules(ImageCacheTestExec Core Quick Test)
add_unity8_uitest(ImageCache ImageCacheTestExec
    DEPENDS ImageCache-qml
    IMPORT_PATHS ${UNITY_PLUGINPATH}
    )
install(TARGETS ImageCacheTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/ImageCache"
)
install(FILES test.qml
    DESTINATION "${SHELL_APP_DIR}/tests/plugins/ImageCache"
)
install(DIRECTORY graphics
    DESTINATION "${SHELL_APP_DIR}/tests/plugins/ImageCache"
)
