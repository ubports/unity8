# add_qml_test macro
include(QmlTest)

add_subdirectory(plugins)

set(qmltest_DEFAULT_IMPORT_PATHS
  ${CMAKE_CURRENT_BINARY_DIR}/plugins
  ${CMAKE_BINARY_DIR}/tests/utils/modules
)

set(qmltest_DEFAULT_TARGETS qmlunittests)
set(qmltest_DEFAULT_NO_ADD_TEST FALSE)
set(qmltest_DEFAULT_PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=minimal")
add_qml_test(Components AnimationControllerWithSignals)
add_qml_test(Components Carousel)
add_qml_test(Components CrossFadeImage)
add_qml_test(Components MathLocal)
add_qml_test(Components OpenEffect)
add_qml_test(Components RatingStars)
add_qml_test(Components TimeLocal)
add_qml_test(Greeter Clock)
add_qml_test(Panel IndicatorItem)
add_qml_test(utils/Unity/Test UnityTest)

set(qmltest_DEFAULT_TARGETS qmluitests)
set(qmltest_DEFAULT_NO_ADD_TEST TRUE)
set(qmltest_DEFAULT_PROPERTIES "")
add_qml_test(Components DraggingArea)
add_qml_test(Components FilterGrid IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Components ResponsiveFlowView)
add_qml_test(Components ResponsiveGridView)
add_qml_test(Components Revealer)
add_qml_test(Components Showable)
add_qml_test(Components Stage IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS}
                                           ${CMAKE_BINARY_DIR}/tests/mocks
                                           ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Components Tile)
add_qml_test(Components PageHeader)
add_qml_test(Dash Dash IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Dash DashBar IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${CMAKE_CURRENT_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Dash DashContent IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Dash DashPreview)
add_qml_test(Dash GenericLensView IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Dash LensView IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${CMAKE_CURRENT_BINARY_DIR}/plugins)
add_qml_test(Dash PeoplePreview)
add_qml_test(Dash FilterGrids IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins ${CMAKE_CURRENT_SOURCE_DIR}/plugins
                                           ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Apps RunningApplicationsGrid IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/People PeopleFilterGrid IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${CMAKE_CURRENT_SOURCE_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Greeter Lockscreen IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins ${CMAKE_BINARY_DIR}/tests/mocks
                             PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full")
add_qml_test(Greeter Tablet IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins ${CMAKE_BINARY_DIR}/tests/mocks
                            ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full")
add_qml_test(Greeter Phone IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins ${CMAKE_BINARY_DIR}/tests/mocks
                           ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/LightDM/single")
add_qml_test(Greeter Infographics IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins ${CMAKE_BINARY_DIR}/tests/mocks
                                  ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full")
add_qml_test(Hud Hud)
add_qml_test(Hud Result)
add_qml_test(Launcher Launcher IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Notifications Notifications)
add_qml_test(Panel IndicatorRow)
add_qml_test(Panel Indicators)
add_qml_test(Panel MenuContent)
add_qml_test(Panel Overview)
add_qml_test(Panel Panel)
add_qml_test(Panel SearchIndicator)
add_qml_test(Panel/Menus IndicatorMenuWindow IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(SideStage SideStage IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS}
                                              ${CMAKE_BINARY_DIR}/tests/mocks
                                              ${CMAKE_BINARY_DIR}/plugins)
