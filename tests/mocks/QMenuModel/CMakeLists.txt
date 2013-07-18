file(GLOB QMLFILES
    *.qml
    *.js
    qmldir
)

# copy files into build directory for shadow builds
add_custom_target(QMenuModelQmlFiles ALL
    COMMAND cp ${QMLFILES} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${QMLFILES}
)
