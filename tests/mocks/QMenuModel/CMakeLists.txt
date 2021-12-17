include_directories(
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
)

set(QMenuModelQml_SOURCES
  actiondata.h
  actionstateparser.cpp
  dbus-enums.h
  plugin.cpp
  ayatanamenumodel.cpp
)

add_library(QMenuModelQml SHARED ${QMenuModelQml_SOURCES})
target_link_libraries(QMenuModelQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
  Qt5::Core Qt5::Quick
)

set_target_properties(QMenuModelQml PROPERTIES
                      OUTPUT_NAME qmenumodel
                      VERSION 1)

add_lomiri_mock(QMenuModel 1.0 QMenuModel.1 TARGETS QMenuModelQml)
