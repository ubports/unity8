include_directories(
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
# FIXME There's no cmake var for this :-/
    /usr/include/qt5/QtV8/5.0.2/QtV8
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader
    ${CMAKE_CURRENT_BINARY_DIR}
    )

remove_definitions(-DQT_NO_KEYWORDS)

add_definitions(-DLISTVIEWWITHPAGEHEADER_FOLDER="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DBUILT_PLUGINS_DIR="${CMAKE_BINARY_DIR}/plugins")

set(testCommand ${CMAKE_CURRENT_BINARY_DIR}/listviewwithpageheadertestExec
        -o ${CMAKE_BINARY_DIR}/testlistviewwithpageheader.xml,xunitxml
        -o -,txt)
add_custom_target(testlistviewwithpageheader ${testCommand})
add_dependencies(qmluitests testlistviewwithpageheader)

add_executable(listviewwithpageheadertestExec listviewwithpageheadertest.cpp ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader/listviewwithpageheader.cpp)
qt5_use_modules(listviewwithpageheadertestExec Test Core Qml)
target_link_libraries(listviewwithpageheadertestExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
