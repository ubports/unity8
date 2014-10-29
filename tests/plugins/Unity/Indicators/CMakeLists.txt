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

    set(testCommand ${CMAKE_CURRENT_BINARY_DIR}/${TEST}Exec
          -o ${CMAKE_BINARY_DIR}/${TEST}.xml,xunitxml
          -o -,txt)
    add_test(NAME ${TEST} COMMAND ${testCommand})
    add_custom_target(${TEST} ${testCommand})
    add_executable(${TEST}Exec
            ${TEST}.cpp
            ${test_ADDITIONAL_CPPS}
        )
    qt5_use_modules(${TEST}Exec Test Core Qml)
    target_link_libraries(${TEST}Exec
        ${test_ADDITIONAL_LIBS}
        ${GLIB_LIBRARIES}
        ${GIO_LIBRARIES}
        ${QMENUMODEL_LDFLAGS}
        )
endmacro(indicator_test)

indicator_test(indicatorsmanagertest ADDITIONAL_LIBS IndicatorsQml)
indicator_test(indicatorsmodeltest ADDITIONAL_LIBS IndicatorsQml)
indicator_test(menucontentactivatortest ADDITIONAL_CPPS ${INDICATORS_DIR}/menucontentactivator.cpp)
indicator_test(unitymenumodelstacktest ADDITIONAL_CPPS ${TEST_DIR}/mocks/QMenuModel/unitymenumodel.cpp ${INDICATORS_DIR}/unitymenumodelstack.cpp)
indicator_test(rootactionstatetest ADDITIONAL_LIBS IndicatorsQml)
indicator_test(sharedunitymenumodeltest ADDITIONAL_LIBS IndicatorsQml)
