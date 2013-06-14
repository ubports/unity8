include(FindPkgConfig)
find_package(Qt5Qml)
find_package(Qt5Quick)
find_package(Qt5Gui)

add_executable(uqmlscene
    ${shellapplication_MOC_SRCS}
    main.cpp
    ../../MouseTouchAdaptor.cpp
    )

qt5_use_modules(uqmlscene Qml Quick Test)
pkg_check_modules(XCB REQUIRED xcb)

if (NOT "${XCB_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(uqmlscene PROPERTIES INCLUDE_DIRECTORIES ${XCB_INCLUDE_DIRS})
endif()

target_link_libraries(uqmlscene
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${XCB_LDFLAGS}
    )
