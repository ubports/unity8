file(GLOB QML_JS_FILES *.qml *.js)

install(FILES ${QML_JS_FILES}
    DESTINATION ${SHELL_APP_DIR}
    )

set(QML_DIRS
    Components
    Dash
    graphics
    Greeter
    Panel
    Launcher
    Stages
    Notifications
    Wizard
    )

install(DIRECTORY ${QML_DIRS}
    DESTINATION ${SHELL_APP_DIR}
    )
