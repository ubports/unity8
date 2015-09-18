add_executable(uqmlscene
    ${shellapplication_MOC_SRCS}
    main.cpp
    )

qt5_use_modules(uqmlscene Qml Quick Test)
pkg_check_modules(XCB REQUIRED xcb)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/src
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
)

if (NOT "${XCB_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(uqmlscene PROPERTIES INCLUDE_DIRECTORIES ${XCB_INCLUDE_DIRS})
endif()

target_link_libraries(uqmlscene
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${XCB_LDFLAGS}
    UbuntuGestures
    )
