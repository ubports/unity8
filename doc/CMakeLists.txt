#
# Documentation
#

find_package(Doxygen)
find_program(DOT_EXECUTABLE dot /usr/bin)
find_program(DOXYQML_EXECUTABLE doxyqml /usr/bin)
if (NOT DOXYGEN_FOUND OR NOT DOT_EXECUTABLE OR NOT DOXYQML_EXECUTABLE)
    message(WARNING "Cannot generate documentation: doxygen, doxyqml and/or graphviz not found")
else()
    file(GLOB_RECURSE DOC_FILES
        ${CMAKE_BINARY_DIR}/include/*.h
        ${CMAKE_SOURCE_DIR}/include/*.h
        ${CMAKE_SOURCE_DIR}/src/*.h
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/plugins/*.h
        ${CMAKE_SOURCE_DIR}/plugins/*.cpp
        ${CMAKE_SOURCE_DIR}/plugins/*.qml
        ${CMAKE_SOURCE_DIR}/plugins/*.js
        ${CMAKE_SOURCE_DIR}/qml/*.qml
        ${CMAKE_SOURCE_DIR}/qml/*.js
        ${CMAKE_SOURCE_DIR}/tests/autopilot/*.py
        ${CMAKE_SOURCE_DIR}/tests/utils/*.h
        ${CMAKE_SOURCE_DIR}/tests/utils/*.cpp
        ${CMAKE_SOURCE_DIR}/tests/utils/*.qml
        ${CMAKE_SOURCE_DIR}/tests/utils/*.js
        ${CMAKE_SOURCE_DIR}/tests/autopilot/unity8/shell/emulators/*.py
        ${CMAKE_SOURCE_DIR}/tests/autopilot/unity8/process_helpers.py)

    string(REPLACE ";" " " DOXYGEN_INPUT "${DOC_FILES}")

    configure_file(${PROJECT_SOURCE_DIR}/doc/Doxyfile.in ${PROJECT_BINARY_DIR}/doc/Doxyfile @ONLY IMMEDIATE)
    add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/doc/${PROJECT_NAME}/index.html
                       COMMAND ${DOXYGEN_EXECUTABLE} ${PROJECT_BINARY_DIR}/doc/Doxyfile
                       DEPENDS ${PROJECT_BINARY_DIR}/doc/Doxyfile ${DOC_FILES})
    add_custom_target(doc DEPENDS ${PROJECT_BINARY_DIR}/doc/${PROJECT_NAME}/index.html)
    install(DIRECTORY ${PROJECT_BINARY_DIR}/doc/${PROJECT_NAME}
            DESTINATION ${CMAKE_INSTALL_PREFIX}/share/doc
            OPTIONAL)
endif()
