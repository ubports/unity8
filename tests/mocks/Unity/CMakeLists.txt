add_subdirectory(Application)
add_subdirectory(Connectivity)
add_subdirectory(Indicators)
add_subdirectory(InputInfo)
add_subdirectory(Launcher)
add_subdirectory(Notifications)
add_subdirectory(DashCommunicator)
add_subdirectory(Screens)

pkg_search_module(GOBJECT gobject-2.0 REQUIRED)
pkg_check_modules(SCOPES_API REQUIRED unity-shell-scopes=11)

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${Qt5Core_INCLUDE_DIRS}
  ${Qt5Quick_INCLUDE_DIRS}
  ${GOBJECT_INCLUDE_DIRS}
)

add_definitions(-DQT_NO_KEYWORDS)

set(UnityQML_SOURCES
  fake_scope.cpp
  fake_scopes.cpp
  fake_scopesoverview.cpp
  fake_settingsmodel.cpp
  fake_categories.cpp
  fake_navigation.cpp
  fake_resultsmodel.cpp
  fake_previewmodel.cpp
  fake_previewwidgetmodel.cpp
  fake_unity_plugin.cpp
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/CategoriesInterface.h
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/NavigationInterface.h
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/PreviewModelInterface.h
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/PreviewWidgetModelInterface.h
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/ResultsModelInterface.h
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/ScopeInterface.h
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/ScopesInterface.h
  ${SCOPES_API_INCLUDEDIR}/unity/shell/scopes/SettingsModelInterface.h
)

# Workaround for gcc failure LP: #1417664
set_source_files_properties(fake_scopes.cpp PROPERTIES COMPILE_FLAGS -O1)

add_library(FakeUnityQml MODULE ${UnityQML_SOURCES})
target_link_libraries(FakeUnityQml
  ${Qt5Core_LIBRARIES}
  ${Qt5Quick_LIBRARIES}
  ${GOBJECT_LDFLAGS}
)

qt5_use_modules(FakeUnityQml Qml)

add_unity8_mock(Unity 0.2 Unity PREFIX scopefakes TARGETS FakeUnityQml)
