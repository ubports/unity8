add_library(MockAccountsService-qml MODULE
    AccountsService.cpp
    plugin.cpp
    )

qt5_use_modules(MockAccountsService-qml DBus Qml)

add_unity8_mock(AccountsService 0.1 AccountsService
    PREFIX mocks
    TARGETS MockAccountsService-qml
    )
