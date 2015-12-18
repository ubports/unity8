pkg_check_modules(GLIB REQUIRED glib-2.0>=2.32)
pkg_check_modules(GIO REQUIRED gio-2.0>=2.32)
pkg_check_modules(QMENUMODEL REQUIRED qmenumodel)

set(INDICATORS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../plugins/Unity/Indicators)
set(TEST_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${INDICATORS_DIR}
    ${TEST_DIR}/mocks/QMenuModel
    ${GLIB_INCLUDE_DIRS}
    ${GIO_INCLUDE_DIRS}
    )

macro(indicator_test TEST)
    set(multi_value_keywords ADDITIONAL_CPPS ADDITIONAL_LIBS)
    cmake_parse_arguments(test "" "" "${multi_value_keywords}" ${ARGN})

    add_executable(${TEST}Exec
            ${TEST}Test.cpp
            ${test_ADDITIONAL_CPPS}
        )
    qt5_use_modules(${TEST}Exec Test Core Qml DBus)
    target_link_libraries(${TEST}Exec
        ${test_ADDITIONAL_LIBS}
        ${GLIB_LIBRARIES}
        ${GIO_LIBRARIES}
        ${QMENUMODEL_LDFLAGS}
        )

    add_unity8_unittest(${TEST} ${TEST}Exec)
endmacro(indicator_test)

indicator_test(IndicatorsManager ADDITIONAL_LIBS IndicatorsQml)
indicator_test(IndicatorsModel ADDITIONAL_LIBS IndicatorsQml)
indicator_test(MenuContentActivator ADDITIONAL_CPPS ${INDICATORS_DIR}/menucontentactivator.cpp)
indicator_test(UnityMenuModelStack ADDITIONAL_CPPS ${TEST_DIR}/mocks/QMenuModel/unitymenumodel.cpp ${INDICATORS_DIR}/unitymenumodelstack.cpp)
indicator_test(RootActionState ADDITIONAL_LIBS IndicatorsQml)
indicator_test(SharedUnityMenuModel ADDITIONAL_LIBS IndicatorsQml)
