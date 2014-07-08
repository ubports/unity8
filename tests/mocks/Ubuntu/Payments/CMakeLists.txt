set(FakeUbuntuPaymentsQml_SOURCES
    plugin.cpp
    MockPayments.cpp
    )

add_library(FakeUbuntuPaymentsQml MODULE ${FakeUbuntuPaymentsQml_SOURCES})

qt5_use_modules(FakeUbuntuPaymentsQml Qml Quick Core)

add_unity8_mock(Ubuntu.Payments 0.1 Ubuntu/Payments TARGETS FakeUbuntuPaymentsQml)
