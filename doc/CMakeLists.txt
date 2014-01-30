#
# Documentation
#

find_package(Doxygen)
find_program(DOT_EXECUTABLE dot /usr/bin)
if (NOT DOXYGEN_FOUND OR NOT DOT_EXECUTABLE)
    message(WARNING "Cannot generate documentation: doxygen and/or graphviz not found")
else()
    configure_file(${PROJECT_SOURCE_DIR}/doc/Doxyfile.in ${PROJECT_BINARY_DIR}/doc/Doxyfile @ONLY IMMEDIATE)
    add_custom_command(OUTPUT ${PROJECT_BINARY_DIR}/doc/${PROJECT_NAME}/index.html
                       COMMAND ${DOXYGEN_EXECUTABLE} ${PROJECT_BINARY_DIR}/doc/Doxyfile
                       DEPENDS ${PROJECT_BINARY_DIR}/doc/Doxyfile)
    add_custom_target(doc ALL
                       DEPENDS ${PROJECT_BINARY_DIR}/doc/${PROJECT_NAME}/index.html)
    install(DIRECTORY ${PROJECT_BINARY_DIR}/doc/${PROJECT_NAME}
            DESTINATION ${CMAKE_INSTALL_PREFIX}/share/doc)
endif()
