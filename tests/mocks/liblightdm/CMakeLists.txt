set(MockLightDM_SOURCES
    MockController.cpp
    MockGreeter.cpp
    MockSessionsModel.cpp
    MockUsersModel.cpp
    )

add_library(MockLightDM SHARED ${MockLightDM_SOURCES})

target_link_libraries(MockLightDM Qt5::DBus Qt5::Gui)

set_target_properties(MockLightDM PROPERTIES
                      OUTPUT_NAME lightdm-qt5-3
                      SOVERSION 0)

install(TARGETS MockLightDM
    DESTINATION ${SHELL_INSTALL_QML}/mocks/liblightdm
    )
