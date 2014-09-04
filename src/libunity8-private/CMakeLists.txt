set(LIB_NAME "unity8-private")

set(lib${LIB_NAME}_SRCS
    abstractdbusservicemonitor.cpp
)

add_library(${LIB_NAME} SHARED
    ${lib${LIB_NAME}_SRCS}
)
qt5_use_modules(${LIB_NAME} DBus)

# install library
install(TARGETS ${LIB_NAME}
     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
