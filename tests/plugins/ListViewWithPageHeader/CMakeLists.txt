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
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader
    ${CMAKE_CURRENT_BINARY_DIR}
    )

remove_definitions(-DQT_NO_KEYWORDS)

add_definitions(-DLISTVIEWWITHPAGEHEADER_FOLDER="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DBUILT_PLUGINS_DIR="${CMAKE_BINARY_DIR}/plugins")

add_executable(listviewwithpageheadertestExec listviewwithpageheadertest.cpp ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader/listviewwithpageheader.cpp)
qt5_use_modules(listviewwithpageheadertestExec Test Core Qml)
target_link_libraries(listviewwithpageheadertestExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
add_custom_target(testlistviewwithpageheader ${CMAKE_CURRENT_BINARY_DIR}/listviewwithpageheadertestExec -o ${CMAKE_BINARY_DIR}/testlistviewwithpageheader.xml,xunitxml -o -,txt)

add_executable(listviewwithpageheadertestsectionExec listviewwithpageheadertestsection.cpp ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader/listviewwithpageheader.cpp)
qt5_use_modules(listviewwithpageheadertestsectionExec Test Core Qml)
target_link_libraries(listviewwithpageheadertestsectionExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
add_custom_target(testlistviewwithpageheadersection ${CMAKE_CURRENT_BINARY_DIR}/listviewwithpageheadertestsectionExec -o ${CMAKE_BINARY_DIR}/testlistviewwithpageheadersection.xml,xunitxml -o -,txt)

add_executable(listviewwithpageheadertestsectionexternalmodelExec listviewwithpageheadertestsectionexternalmodel.cpp ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/ListViewWithPageHeader/listviewwithpageheader.cpp)
qt5_use_modules(listviewwithpageheadertestsectionexternalmodelExec Test Core Qml)
target_link_libraries(listviewwithpageheadertestsectionexternalmodelExec ${Qt5Gui_LIBRARIES} ${Qt5Quick_LIBRARIES})
add_custom_target(testlistviewwithpageheadersectionexternalmodel ${CMAKE_CURRENT_BINARY_DIR}/listviewwithpageheadertestsectionexternalmodelExec -o ${CMAKE_BINARY_DIR}/testlistviewwithpageheadersectionexternalmodel.xml,xunitxml -o -,txt)

set(qmltest_DEFAULT_NO_ADD_TEST TRUE)
add_qml_test(. listviewwithpageheaderqml IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins)

add_dependencies(qmluitests testlistviewwithpageheader)
add_dependencies(qmluitests testlistviewwithpageheadersection)
add_dependencies(qmluitests testlistviewwithpageheadersectionexternalmodel)
add_dependencies(qmluitests testlistviewwithpageheaderqml)
