set(CMAKE_AUTOMOC ON)

include(FindPkgConfig)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
)

add_definitions(-DQT_NO_KEYWORDS)

set(GSettingsQML_SOURCES
  fake_gsettings.cpp
  plugin.cpp
)

add_library(FakeGSettingsQml MODULE ${GSettingsQML_SOURCES})
target_link_libraries(FakeGSettingsQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
)

qt5_use_modules(FakeGSettingsQml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )
