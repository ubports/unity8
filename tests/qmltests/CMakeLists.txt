# add_qml_test macro
include(QmlTest)

add_subdirectory(Components)

set(qmltest_DEFAULT_IMPORT_PATHS
  ${CMAKE_BINARY_DIR}/tests/utils/modules
  ${CMAKE_BINARY_DIR}/tests/mocks
)

set(qmltest_DEFAULT_TARGETS qmlunittests)
set(qmltest_DEFAULT_NO_ADD_TEST FALSE)
set(qmltest_DEFAULT_PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=minimal")
add_qml_test(Panel IndicatorItem)
add_qml_test(utils/Unity/Test UnityTest)

set(qmltest_DEFAULT_TARGETS qmluitests)
set(qmltest_DEFAULT_NO_ADD_TEST TRUE)
set(qmltest_DEFAULT_PROPERTIES ENVIRONMENT "LC_ALL=C")

add_qml_test(. Shell IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks
                     ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/LightDM/single")
add_qml_test(Components Carousel)
add_qml_test(Components DraggingArea)
add_qml_test(Components EdgeDemoOverlay)
add_qml_test(Components FilterGrid IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Components LazyImage)
add_qml_test(Components Rating)
add_qml_test(Components ResponsiveFlowView)
add_qml_test(Components ResponsiveGridView)
add_qml_test(Components Revealer)
add_qml_test(Components SeeMore)
add_qml_test(Components Showable)
add_qml_test(Components PageHeaderLabel)
add_qml_test(Dash Dash IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Dash DashContent IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Dash Card)
add_qml_benchmark(Dash CardBenchmark 1000)
add_qml_test(Dash CardHeader)
add_qml_test(Dash CardTool)
add_qml_test(Dash GenericScopeView IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Dash/Apps RunningApplicationsGrid IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS}
                                                            ${CMAKE_BINARY_DIR}/tests/mocks
                                                            ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Dash/Previews Preview IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewActions IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewAudioPlayback IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewHeader IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewImageGallery IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewProgress IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewRatingDisplay IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewRatingInput IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewTextSummary IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewVideoPlayback IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewWidgetFactory IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Dash/Previews PreviewZoomableImage IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/tests/mocks)
add_qml_test(Greeter Lockscreen IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS}
                             PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/libusermetrics:${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full")
add_qml_test(Greeter Tablet IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS}
                            ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/libusermetrics:${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full")
add_qml_test(Greeter Phone IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS}
                           ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/libusermetrics:${CMAKE_BINARY_DIR}/tests/mocks/LightDM/single")
add_qml_test(Greeter Infographics IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS}
                                  ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/libusermetrics:${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full")
add_qml_test(Greeter Clock IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS}
                           ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/QMenuModel")
add_qml_test(Hud Hud)
add_qml_test(Hud Result)
add_qml_test(Launcher Launcher IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Notifications Notifications IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Notifications VisualSnapDecisionsQueue IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Panel ActiveCallHint)
add_qml_test(Panel IndicatorRow)
add_qml_test(Panel Indicators IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Panel MenuContent IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Panel Panel IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS})
add_qml_test(Panel SearchIndicator)
add_qml_test(Panel/Indicators DefaultIndicatorWidget IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS}
                                                  ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/QMenuModel")
add_qml_test(Panel/Indicators DefaultIndicatorPage IMPORT_PATHS ${CMAKE_BINARY_DIR}/plugins ${qmltest_DEFAULT_IMPORT_PATHS}
                                                  ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/QMenuModel")
add_qml_test(Panel/Indicators MenuItemFactory IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Panel/Indicators MessageMenuItemFactory IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS} ${CMAKE_BINARY_DIR}/plugins)
add_qml_test(Stages PhoneStage IMPORT_PATHS ${qmltest_DEFAULT_IMPORT_PATHS}
                                              ${CMAKE_BINARY_DIR}/tests/mocks
                                              ${CMAKE_BINARY_DIR}/plugins)
