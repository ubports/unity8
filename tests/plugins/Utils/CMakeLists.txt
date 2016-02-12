include_directories(
    ${UtilsQmlPlugin_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/Utils
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_definitions(-DCONFIG_TESTING)

foreach(util_test
    QLimitProxyModel
    UnitySortFilterProxyModel
    WindowInputMonitor
    DeviceConfigParser
)
    add_executable(${util_test}TestExec ${util_test}Test.cpp ModelTest.cpp)
    qt5_use_modules(${util_test}TestExec Test Core Qml)
    target_link_libraries(${util_test}TestExec Utils-qml)
    add_unity8_unittest(${util_test} ${util_test}TestExec ADD_TEST)
endforeach()

# plain qml test
add_unity8_qmlunittest(. UtilsStyle)
