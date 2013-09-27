file(GLOB QMLFILES
    *.qml
    *.js
    qmldir
)

# copy files into build directory for shadow builds
add_custom_target(QMenuModelQmlFiles ALL
    COMMAND cp ${QMLFILES} ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${QMLFILES}
)

include_directories(
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
)

set(QMenuModelQml_SOURCES
  plugin.cpp
  unitymenumodel.cpp
)

add_library(QMenuModelQml MODULE ${QMenuModelQml_SOURCES})
target_link_libraries(QMenuModelQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
)

qt5_use_modules(QMenuModelQml Core Quick)
