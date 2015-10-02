pkg_check_modules(CONNECTIVITY REQUIRED connectivity-qt1)

include_directories(
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
    ${CONNECTIVITY_INCLUDE_DIRS}
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
    ApplicationArguments.cpp
    main.cpp
    MouseTouchAdaptor.cpp
    CachingNetworkManagerFactory.cpp
    SecondaryWindow.cpp
    ShellApplication.cpp
    ShellView.cpp
    UnityCommandLineParser.cpp
    ${QML_FILES} # This is to make qml and image files appear in the IDE's project tree
)

qt5_use_modules(${SHELL_APP} Gui Qml Quick Test)

pkg_check_modules(NEEDED_LIBS REQUIRED xcb libandroid-properties)
if (NOT "${NEEDED_LIBS_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(${SHELL_APP} PROPERTIES INCLUDE_DIRECTORIES ${NEEDED_LIBS_INCLUDE_DIRS})
endif()
target_link_libraries(${SHELL_APP} ${NEEDED_LIBS_LDFLAGS})

target_link_libraries(${SHELL_APP} UbuntuGestures connectivity-qt1)

# For it to find libUbuntuGestures.so
set_target_properties(${SHELL_APP} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}")

# install binaries
install(TARGETS ${SHELL_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
     )

add_subdirectory(Panel)
add_subdirectory(Dash)
add_subdirectory(libunity8-private)
