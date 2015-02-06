include_directories(
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
)

set(QMenuModelQml_SOURCES
  actiondata.h
  actionstateparser.cpp
  dbus-enums.h
  plugin.cpp
  unitymenumodel.cpp
)

add_library(QMenuModelQml SHARED ${QMenuModelQml_SOURCES})
target_link_libraries(QMenuModelQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
)

qt5_use_modules(QMenuModelQml Core Quick)

set_target_properties(QMenuModelQml PROPERTIES
                      OUTPUT_NAME qmenumodel
                      VERSION 0)

add_unity8_mock(QMenuModel 0.1 QMenuModel TARGETS QMenuModelQml)
