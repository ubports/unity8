add_definitions(-DTOP_SRCDIR="${CMAKE_SOURCE_DIR}")

add_library(MockAccountsService-qml MODULE
    AccountsService.cpp
    plugin.cpp
    )

qt5_use_modules(MockAccountsService-qml DBus Qml)

add_unity8_mock(AccountsService 0.1 AccountsService TARGETS MockAccountsService-qml)
