add_subdirectory(libunity8-private)

pkg_check_modules(CONNECTIVITY REQUIRED connectivity-qt1)
pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${GSETTINGS_QT_INCLUDE_DIRS}
    ${CONNECTIVITY_INCLUDE_DIRS}
)

include_directories(
    ${libunity8-private_SOURCE_DIR}
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
    UnixSignalHandler.cpp
    DebuggingController.cpp
    ${QML_FILES} # This is to make qml and image files appear in the IDE's project tree
)

if (ENABLE_TOUCH_EMULATION)
    set(SOURCE_FILES ${SOURCE_FILES} MouseTouchAdaptor.cpp)
endif()

add_executable(${SHELL_APP} ${SOURCE_FILES})

target_link_libraries(${SHELL_APP}
    Qt5::DBus Qt5::Gui Qt5::Qml Qt5::Quick Qt5::Test
    ${GSETTINGS_QT_LDFLAGS}
    UbuntuGestures connectivity-qt1 unity8-private
    )

if (ENABLE_TOUCH_EMULATION)
    target_link_libraries(${SHELL_APP} ${MOUSETOUCHADAPTOR_LIBS_LDFLAGS})
endif()

# install binaries
install(TARGETS ${SHELL_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
     )
