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
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${Qt5V8_PRIVATE_INCLUDE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash
    ${CMAKE_CURRENT_BINARY_DIR}
    )

remove_definitions(-DQT_NO_KEYWORDS)

add_definitions(-DDASHVIEWSTEST_FOLDER="${CMAKE_CURRENT_SOURCE_DIR}")

macro(add_lvwph_test FILENAME TESTNAME)
    add_executable(${TESTNAME}TestExec
        ${FILENAME}test.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/listviewwithpageheader.cpp)
    qt5_use_modules(${TESTNAME}TestExec Test Core Qml)
    target_link_libraries(${TESTNAME}TestExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})

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

    add_unity8_uitest(${TESTNAME} ${TESTNAME}TestExec DEPENDS Dash-qml)

    add_executable(${TESTNAME}TryExec
        ${FILENAME}try.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/${FILENAME}.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Dash/abstractdashview.cpp
    )
    qt5_use_modules(${TESTNAME}TryExec Test Core Qml)
    target_link_libraries(${TESTNAME}TryExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
    add_manual_test(${TESTNAME} ${TESTNAME}TryExec DEPENDS Dash-qml)
endmacro()

add_dashview_try_test(verticaljournal VerticalJournal)
add_dashview_try_test(horizontaljournal HorizontalJournal)
add_dashview_try_test(organicgrid OrganicGrid)

# CardCreator test
add_executable(CardCreatorTestExec cardcreatortest.cpp)
qt5_use_modules(CardCreatorTestExec Test Core Qml)
target_link_libraries(CardCreatorTestExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
add_unity8_uitest(CardCreator CardCreatorTestExec DEPENDS Dash-qml)

# plain qml test
foreach(dash_test ScopeStyle ListViewWithPageHeaderQML CardAttributes CroppedImageMinimumSourceSize)
    add_unity8_qmltest(. ${dash_test})
endforeach()
