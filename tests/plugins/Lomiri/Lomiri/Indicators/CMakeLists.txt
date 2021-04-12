set(INDICATORS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../plugins/Lomiri/Indicators)
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
    target_link_libraries(${TEST}Exec
        Qt5::Test Qt5::Core Qt5::Qml Qt5::DBus
        ${test_ADDITIONAL_LIBS}
        ${GLIB_LIBRARIES}
        ${GIO_LIBRARIES}
        ${QMENUMODEL_LDFLAGS}
        )
    install(TARGETS ${TEST}Exec
        DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Lomiri/Indicators"
        )

    set(ldpath "")
    foreach(lib ${test_ADDITIONAL_LIBS})
        set(ldpath "$<TARGET_FILE_DIR:${lib}>:")
    endforeach(lib)

    add_lomiri_unittest(${TEST} ${TEST}Exec
        ENVIRONMENT "LD_LIBRARY_PATH=${ldpath}"
        )
endmacro(indicator_test)

indicator_test(IndicatorsManager ADDITIONAL_LIBS IndicatorsQml)
indicator_test(IndicatorsModel ADDITIONAL_LIBS IndicatorsQml)
indicator_test(MenuContentActivator ADDITIONAL_CPPS ${INDICATORS_DIR}/menucontentactivator.cpp)
indicator_test(LomiriMenuModelStack ADDITIONAL_CPPS ${TEST_DIR}/mocks/QMenuModel/lomirimenumodel.cpp ${INDICATORS_DIR}/lomirimenumodelstack.cpp)
indicator_test(RootActionState ADDITIONAL_LIBS IndicatorsQml)
indicator_test(SharedLomiriMenuModel ADDITIONAL_LIBS IndicatorsQml)
