pkg_check_modules(UNITY-MIR REQUIRED unity-mir)

include_directories(
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${UNITY-MIR_INCLUDE_DIRS}
)

add_executable(${SHELL_APP}
    ${CMAKE_SOURCE_DIR}/include/ApplicationArguments.h
    main.cpp
    MouseTouchAdaptor.cpp
    )

qt5_use_modules(${SHELL_APP} Gui Qml Quick Test)
pkg_check_modules(XCB REQUIRED xcb)

if (NOT "${XCB_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(${SHELL_APP} PROPERTIES INCLUDE_DIRECTORIES ${XCB_INCLUDE_DIRS})

    target_link_libraries(${SHELL_APP} ${XCB_LDFLAGS})
endif()

# install binaries
install(TARGETS ${SHELL_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
     )

add_subdirectory(Panel)
