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
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    AccountsService.cpp
    plugin.cpp
    )

qt5_use_modules(MockAccountsService-qml DBus Qml)

target_link_libraries(MockAccountsService-qml
    MockLightDM
    )

add_unity8_mock(AccountsService 0.1 AccountsService
    TARGETS MockAccountsService-qml
    )
