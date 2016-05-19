include(QmlTest)

set(UNITY_IMPORT_PATHS
    ${CMAKE_BINARY_DIR}/tests/utils/modules
    ${UNITY_PLUGINPATH}
)

add_manual_qml_test(. Cursor IMPORT_PATHS ${UNITY_IMPORT_PATHS})
