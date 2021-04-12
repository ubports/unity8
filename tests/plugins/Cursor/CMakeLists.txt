include(QmlTest)

set(LOMIRI_IMPORT_PATHS
    ${CMAKE_BINARY_DIR}/tests/utils/modules
    ${LOMIRI_PLUGINPATH}
)

add_manual_qml_test(. Cursor IMPORT_PATHS ${LOMIRI_IMPORT_PATHS})
