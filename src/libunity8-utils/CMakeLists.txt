set(UTILS_SRC
    abstractdbusservicemonitor.cpp
)

add_library(unity8-utils SHARED
    ${UTILS_SRC}
)
qt5_use_modules(unity8-utils DBus)

# install library
install(TARGETS unity8-utils
     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
