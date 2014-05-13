file(GLOB QML_JS_FILES *.qml *.js)

install(FILES ${QML_JS_FILES}
    DESTINATION ${SHELL_APP_DIR}
    )

set(QML_DIRS
    Bottombar
    Components
    Dash
    graphics
    Greeter
    Hud
    Panel
    Launcher
    Stages
    Notifications
    )

install(DIRECTORY ${QML_DIRS}
    DESTINATION ${SHELL_APP_DIR}
    )
