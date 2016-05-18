pkg_check_modules(CONNECTIVITY REQUIRED connectivity-qt1)

include_directories(
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
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

set(SOURCE_FILES
    ApplicationArguments.cpp
    main.cpp
    CachingNetworkManagerFactory.cpp
    SecondaryWindow.cpp
    ShellApplication.cpp
    ShellView.cpp
    UnityCommandLineParser.cpp
    ${QML_FILES} # This is to make qml and image files appear in the IDE's project tree
)

if (ENABLE_TOUCH_EMULATION)
    set(SOURCE_FILES ${SOURCE_FILES} MouseTouchAdaptor.cpp)
endif()

pkg_check_modules(ANDROID_PROPERTIES REQUIRED libandroid-properties)
add_executable(${SHELL_APP} ${SOURCE_FILES})
qt5_use_modules(${SHELL_APP} DBus Gui Qml Quick Test)

if (NOT "${ANDROID_PROPERTIES_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(${SHELL_APP} PROPERTIES INCLUDE_DIRECTORIES ${ANDROID_PROPERTIES_INCLUDE_DIRS})
endif()
target_link_libraries(${SHELL_APP} ${ANDROID_PROPERTIES_LDFLAGS} UbuntuGestures connectivity-qt1)

if (ENABLE_TOUCH_EMULATION)
    target_link_libraries(${SHELL_APP} ${MOUSETOUCHADAPTOR_LIBS_LDFLAGS})
endif()

# install binaries
install(TARGETS ${SHELL_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
     )

add_subdirectory(Panel)
add_subdirectory(Dash)
add_subdirectory(libunity8-private)
