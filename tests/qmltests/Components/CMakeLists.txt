add_definitions(-DTEST_DIR="${CMAKE_CURRENT_LIST_DIR}")

pkg_check_modules(UBUNTUGESTURES REQUIRED UbuntuGestures)

########## tst_DragHandle

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Ubuntu/Gestures
    ${UBUNTUGESTURES_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${UBUNTUGESTURES_INCLUDEDIR}/UbuntuGestures/${UBUNTUGESTURES_VERSION}
    )

add_executable(DragHandleTestExec tst_DragHandle.cpp)
qt5_use_modules(DragHandleTestExec Test Core Qml Gui Quick)
target_link_libraries(DragHandleTestExec UbuntuGesturesQml ${UBUNTUGESTURES_LIBRARIES})

add_unity8_uitest(DragHandle DragHandleTestExec ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures)
add_manual_qml_test(. DragHandle IMPORT_PATHS ${UNITY_IMPORT_PATHS})

########## tst_EdgeDragEvaluator
add_executable(EdgeDragEvaluatorTestExec tst_EdgeDragEvaluator.cpp)
qt5_use_modules(EdgeDragEvaluatorTestExec Test Core Qml Gui Quick)
target_link_libraries(EdgeDragEvaluatorTestExec UbuntuGesturesQml ${UBUNTUGESTURES_LIBRARIES})

add_unity8_uitest(EdgeDragEvaluator EdgeDragEvaluatorTestExec ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/Ubuntu/Gestures)
