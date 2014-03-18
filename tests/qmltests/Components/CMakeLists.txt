########## tst_DragHandle

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Ubuntu/Gestures
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    )

set(testCommand
      LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures
      ${CMAKE_CURRENT_BINARY_DIR}/DragHandleTestExec
      -o ${CMAKE_BINARY_DIR}/DragHandleTest.xml,xunitxml
      -o -,txt)

add_custom_target(testDragHandle ${testCommand})
add_dependencies(testDragHandle DragHandleTestExec)

set(xvfbtestCommand
      LD_PRELOAD=/usr/lib/x86_64-linux-gnu/mesa/libGL.so.1
      LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures
      xvfb-run --server-args "-screen 0 1024x768x24" --auto-servernum
      ${CMAKE_CURRENT_BINARY_DIR}/DragHandleTestExec
      -o ${CMAKE_BINARY_DIR}/DragHandleTest.xml,xunitxml
      -o -,txt)

add_custom_target(xvfbtestDragHandle ${xvfbtestCommand})
add_dependencies(xvfbtestDragHandle DragHandleTestExec)

add_dependencies(qmluitests xvfbtestDragHandle)

add_executable(DragHandleTestExec tst_DragHandle.cpp)
qt5_use_modules(DragHandleTestExec Test Core Qml Gui Quick)
target_link_libraries(DragHandleTestExec UbuntuGestureQml)

add_definitions(-DUBUNTU_GESTURES_PLUGIN_DIR="${CMAKE_BINARY_DIR}/plugins")
add_definitions(-DTEST_DIR="${CMAKE_CURRENT_LIST_DIR}")
