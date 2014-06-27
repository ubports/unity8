include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(PAYMENTS_SOURCES
    plugin.cpp
    Payments.cpp
    )

add_library(Payments MODULE ${PAYMENTS_SOURCES})

qt5_use_modules(Payments Qml Quick DBus Core)

add_unity8_plugin(Ubuntu.Payments 0.1 Ubuntu/Payments TARGETS Payments)

pkg_check_modules(LIBPAY REQUIRED pay-1)
add_definitions(${LIBPAY_CFLAGS} ${LIBPAY_CFLAGS_OTHER})

target_link_libraries(Payments ${LIBPAY_LDFLAGS})
