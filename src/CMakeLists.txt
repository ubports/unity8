pkg_check_modules(UNITY-MIR REQUIRED unity-mir)

include_directories(
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${UNITY-MIR_INCLUDE_DIRS}
)

file(GLOB_RECURSE QML_FILES
    ${CMAKE_SOURCE_DIR}/qml/*
    ${CMAKE_SOURCE_DIR}/tests/*.qml
    ${CMAKE_SOURCE_DIR}/tests/*.js
    ${CMAKE_SOURCE_DIR}/tests/*.jpg
    ${CMAKE_SOURCE_DIR}/tests/*.png
    ${CMAKE_SOURCE_DIR}/tests/*.sci
    ${CMAKE_SOURCE_DIR}/tests/*.svg
)

add_executable(${SHELL_APP}
    ApplicationArguments.h
    main.cpp
    MouseTouchAdaptor.cpp
    CachingNetworkManagerFactory.cpp
    ${QML_FILES} # This is to make qml and image files appear in the IDE's project tree
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
