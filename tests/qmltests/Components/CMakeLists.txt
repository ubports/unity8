add_definitions(-DTEST_DIR="qmltests/Components")

pkg_check_modules(LOMIRIGESTURES REQUIRED LomiriGestures)

########## tst_DragHandle

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Gestures
    ${CMAKE_CURRENT_BINARY_DIR}
    )

include_directories(
    SYSTEM
    ${LOMIRIGESTURES_INCLUDE_DIRS}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${LOMIRIGESTURES_INCLUDEDIR}/LomiriGestures/${LOMIRIGESTURES_VERSION}
    )

add_executable(DragHandleTestExec tst_DragHandle.cpp)
target_link_libraries(DragHandleTestExec
    Qt5::Test Qt5::Core Qt5::Qml Qt5::Gui Qt5::Quick
    LomiriGesturesQml ${LOMIRIGESTURES_LIBRARIES}
    )
install(TARGETS DragHandleTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/qmltests/Components"
    )
set_target_properties(DragHandleTestExec PROPERTIES
    INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/Lomiri/Gestures:${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}"
    )

add_unity8_uitest(DragHandle DragHandleTestExec)
add_manual_qml_test(. DragHandle IMPORT_PATHS ${UNITY_IMPORT_PATHS})
add_unity8_qmltest_data(. tst_DragHandle.qml)
add_unity8_qmltest_data(. tst_DragHandle)

########## tst_EdgeDragEvaluator
add_executable(EdgeDragEvaluatorTestExec tst_EdgeDragEvaluator.cpp)
target_link_libraries(EdgeDragEvaluatorTestExec
    Qt5::Test Qt5::Core Qt5::Qml Qt5::Gui Qt5::Quick
    LomiriGesturesQml ${LOMIRIGESTURES_LIBRARIES}
    )
install(TARGETS EdgeDragEvaluatorTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/qmltests/Components"
    )
set_target_properties(EdgeDragEvaluatorTestExec PROPERTIES
    INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/Lomiri/Gestures:${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}"
    )

add_unity8_uitest(EdgeDragEvaluator EdgeDragEvaluatorTestExec)
add_unity8_qmltest_data(. tst_EdgeDragEvaluator.qml)
