include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    )

add_library(MockAccountsService-qml MODULE
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/PromptsModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/lomirisortfilterproxymodelqml.cpp
    AccountsService.cpp
    plugin.cpp
    )

target_link_libraries(MockAccountsService-qml
    Qt5::DBus Qt5::Qml
    MockLightDM
    )

add_lomiri_mock(AccountsService 0.1 AccountsService
    TARGETS MockAccountsService-qml
    )
