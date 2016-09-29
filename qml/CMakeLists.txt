file(GLOB QML_JS_FILES *.qml *.js)

install(FILES ${QML_JS_FILES}
    DESTINATION ${SHELL_APP_DIR}
    )

set(QML_DIRS
    ApplicationMenus
    Components
    Dash
    graphics
    Greeter
    Launcher
    Notifications
    Panel
    Stages
    Rotation
    Tutorial
    Wizard
    )

install(DIRECTORY ${QML_DIRS}
    DESTINATION ${SHELL_APP_DIR}
    )
