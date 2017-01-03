# add_qml_test macro
include(QmlTest)

# There's no cmake var for v8 include path :-/
# so create one
LIST(GET Qt5Core_INCLUDE_DIRS 0 QtCoreDir0)
if(${Qt5Core_VERSION_STRING} VERSION_LESS "5.1.0")
    SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/../QtV8/${Qt5Core_VERSION_STRING}/QtV8)
else()
    SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/QtV8/${Qt5Core_VERSION_STRING}/QtV8)
endif()


include_directories(
    SYSTEM
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${Qt5V8_PRIVATE_INCLUDE_DIR}
    )

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash
    ${CMAKE_CURRENT_BINARY_DIR}
    )

remove_definitions(-DQT_NO_KEYWORDS)

add_definitions(-DTEST_DIR="plugins/Dash")

macro(add_lvwph_test FILENAME TESTNAME)
    add_executable(${TESTNAME}TestExec
        ${FILENAME}test.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/listviewwithpageheader.cpp)
    qt5_use_modules(${TESTNAME}TestExec Test Core Qml)
    target_link_libraries(${TESTNAME}TestExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
    install(TARGETS ${TESTNAME}TestExec
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Dash"
    )

    add_unity8_uitest(${TESTNAME} ${TESTNAME}TestExec DEPENDS Dash-qml)
endmacro()

add_lvwph_test(listviewwithpageheader ListViewWithPageHeader)
add_lvwph_test(listviewwithpageheadersection ListViewWithPageHeaderSection)
add_lvwph_test(listviewwithpageheadersectionexternalmodel ListViewWithPageHeaderSectionExternalModel)

macro(add_dashview_try_test FILENAME TESTNAME)
    add_executable(${TESTNAME}TestExec
        ${FILENAME}test.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/${FILENAME}.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/abstractdashview.cpp
    )
    qt5_use_modules(${TESTNAME}TestExec Test Core Qml)
    target_link_libraries(${TESTNAME}TestExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
    install(TARGETS ${TESTNAME}TestExec
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Dash"
    )

    add_unity8_uitest(${TESTNAME} ${TESTNAME}TestExec DEPENDS Dash-qml)

    add_executable(${TESTNAME}TryExec
        ${FILENAME}try.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/${FILENAME}.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/abstractdashview.cpp
    )
    qt5_use_modules(${TESTNAME}TryExec Test Core Qml)
    target_link_libraries(${TESTNAME}TryExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
    install(TARGETS ${TESTNAME}TryExec
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Dash"
    )
    add_manual_test(${TESTNAME} ${TESTNAME}TryExec DEPENDS Dash-qml)
endmacro()

add_dashview_try_test(verticaljournal VerticalJournal)
add_dashview_try_test(horizontaljournal HorizontalJournal)
add_dashview_try_test(organicgrid OrganicGrid)

# Install data files needed for tests
file(GLOB qml_files RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" *.qml)
foreach(qml_file ${qml_files})
    add_qml_test_data(. "${qml_file}")
endforeach()

# CardCreator test
add_executable(CardCreatorTestExec cardcreatortest.cpp)
qt5_use_modules(CardCreatorTestExec Test Core Qml)
target_link_libraries(CardCreatorTestExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
install(TARGETS CardCreatorTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Dash"
)
add_unity8_uitest(CardCreator CardCreatorTestExec DEPENDS Dash-qml)
add_qml_test_data(. cardcreator)

# This one qml file imports a file in an arch-specific directory, so to make its
# import line relative, we install it into an arch-specific directory too.
add_qml_test_data(. cardcreatortest.qml
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Dash"
)

# plain qml test
foreach(dash_test ScopeStyle ListViewWithPageHeaderQML CardAttributes CroppedImageMinimumSourceSize)
    add_unity8_qmltest(. ${dash_test})
endforeach()
