# QML tests that do not require graphical capabilities.
add_custom_target(qmlunittests)

# QML tests that require graphical capabilities.
add_custom_target(qmluitests)

add_custom_target(qmltests)
add_dependencies(qmltests qmlunittests qmluitests)

add_subdirectory(qmltests)
add_subdirectory(mocks)
add_subdirectory(whitespace)
add_subdirectory(plugins)
add_subdirectory(utils)
add_subdirectory(uqmlscene)
