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

set(COMMON_SRCS
    ApplicationArguments.h
    main.cpp
    MouseTouchAdaptor.cpp
    ${QML_FILES} # This is to make qml and image files appear in the IDE's project tree
    )
add_executable(${SHELL_APP} ${COMMON_SRCS})
add_executable(${GREETER_APP} ${COMMON_SRCS})

set_target_properties(${SHELL_APP} PROPERTIES
    COMPILE_DEFINITIONS "UNITY8_GREETER=0"
    )
set_target_properties(${GREETER_APP} PROPERTIES
    COMPILE_DEFINITIONS "UNITY8_GREETER=1"
    )

qt5_use_modules(${SHELL_APP} Gui Qml Quick Test)
qt5_use_modules(${GREETER_APP} Gui Qml Quick Test)
pkg_check_modules(XCB REQUIRED xcb)

if (NOT "${XCB_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(${SHELL_APP} PROPERTIES INCLUDE_DIRECTORIES ${XCB_INCLUDE_DIRS})
    set_target_properties(${GREETER_APP} PROPERTIES INCLUDE_DIRECTORIES ${XCB_INCLUDE_DIRS})

    target_link_libraries(${SHELL_APP} ${XCB_LDFLAGS})
    target_link_libraries(${GREETER_APP} ${XCB_LDFLAGS})
endif()

# install binaries
install(TARGETS ${SHELL_APP} ${GREETER_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
     )

add_subdirectory(Panel)
