add_executable(tst-pagelist tst_pagelist.cpp ${CMAKE_SOURCE_DIR}/wizard/PageList.cpp)
set_target_properties(tst-pagelist PROPERTIES
                      INCLUDE_DIRECTORIES "${CMAKE_CURRENT_BINARY_DIR};${CMAKE_SOURCE_DIR}/wizard")
qt5_use_modules(tst-pagelist Core Test)
add_test(tst-pagelist tst-pagelist)
