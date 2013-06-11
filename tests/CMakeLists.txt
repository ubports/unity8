# QML tests that do not require graphical capabitlies.
add_custom_target(qmlunittests)

# QML tests that require graphical capabitlies.
add_custom_target(qmluitests)

add_custom_target(qmltests)
add_dependencies(qmltests qmlunittests qmluitests)

add_subdirectory(qmltests)
add_subdirectory(mocks)
add_subdirectory(whitespace)
add_subdirectory(plugins)
add_subdirectory(modules)
add_subdirectory(utils)
