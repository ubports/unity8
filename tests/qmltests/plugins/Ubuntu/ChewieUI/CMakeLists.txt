set(CMAKE_AUTOMOC ON)

include(FindPkgConfig)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden -Wall -Wextra -std=c++11")

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
)

add_definitions(-DQT_NO_KEYWORDS)

set(ChewieUIQML_SOURCES
  fake_chewie_plugin.cpp
  fake_pluginmodel.cpp
)

add_library(FakeChewieUIQml MODULE ${ChewieUIQML_SOURCES})
target_link_libraries(FakeChewieUIQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
)

qt5_use_modules(FakeChewieUIQml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )
