set(mock_SOURCES
    ColorTheme.cpp
    UserMetrics.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qvariantlistmodel.cpp
    )

add_library(MockUserMetrics SHARED ${mock_SOURCES})

qt5_use_modules(MockUserMetrics Gui)

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_CURRENT_BINARY_DIR}
)

set_target_properties(MockUserMetrics PROPERTIES
                      OUTPUT_NAME usermetricsoutput
                      VERSION 1)

install(TARGETS MockUserMetrics
    DESTINATION ${SHELL_INSTALL_QML}/mocks/libusermetrics
    )
