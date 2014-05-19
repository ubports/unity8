add_subdirectory(Application)
add_subdirectory(Indicators)
add_subdirectory(Launcher)
add_subdirectory(Notifications)

pkg_search_module(DEE dee-1.0 REQUIRED)
pkg_search_module(GOBJECT gobject-2.0 REQUIRED)
pkg_search_module(DEEQT libdee-qt5 REQUIRED)

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
  ${DEE_INCLUDE_DIRS}
  ${DEEQT_INCLUDE_DIRS}
)

add_definitions(-DQT_NO_KEYWORDS)

set(UnityQML_SOURCES
  fake_scope.cpp
  fake_scopes.cpp
  fake_categories.cpp
  fake_resultsmodel.cpp
  fake_previewmodel.cpp
  fake_previewstack.cpp
  fake_previewwidgetmodel.cpp
  fake_unity_plugin.cpp
)

add_library(FakeUnityQml MODULE ${UnityQML_SOURCES})
target_link_libraries(FakeUnityQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
  ${DEEQT_LDFLAGS}
  ${GOBJECT_LDFLAGS}
)

qt5_use_modules(FakeUnityQml Qml)

add_unity8_mock(Unity 0.2 Unity PREFIX scopefakes TARGETS FakeUnityQml)
