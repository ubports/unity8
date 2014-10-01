########## tst_DragHandle

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Ubuntu/Gestures
    ${CMAKE_SOURCE_DIR}/libs/UbuntuGestures
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    )

add_executable(DragHandleTestExec tst_DragHandle.cpp)
qt5_use_modules(DragHandleTestExec Test Core Qml Gui Quick)
target_link_libraries(DragHandleTestExec UbuntuGesturesQml UbuntuGestures)

add_binary_qml_test(DragHandle ${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures "")
add_manual_qml_test(. DragHandle IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins)

add_definitions(-DUBUNTU_GESTURES_PLUGIN_DIR="${CMAKE_BINARY_DIR}/plugins")
add_definitions(-DTEST_DIR="${CMAKE_CURRENT_LIST_DIR}")
