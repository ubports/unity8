find_package(QmlPlugins)

add_definitions(-DQT_NO_KEYWORDS)

pkg_check_modules(LOMIRIGESTURES REQUIRED LomiriGestures)

include_directories(
    ${CMAKE_SOURCE_DIR}/src
)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${LOMIRIGESTURES_INCLUDE_DIRS}
    ${LOMIRIGESTURES_INCLUDEDIR}/LomiriGestures/${LOMIRIGESTURES_VERSION}
)

set(LomiriTestQML_SOURCES
    testutil.cpp
    plugin.cpp
    TouchEventSequenceWrapper.cpp
)

if (ENABLE_TOUCH_EMULATION)
    set(LomiriTestQML_SOURCES ${LomiriTestQML_SOURCES} ${CMAKE_SOURCE_DIR}/src/MouseTouchAdaptor.cpp)
endif()

add_library(LomiriTestQml MODULE ${LomiriTestQML_SOURCES})
target_link_libraries(LomiriTestQml ${LOMIRIGESTURES_LIBRARIES} Qt5::Core Qt5::Quick Qt5::Test)

if (ENABLE_TOUCH_EMULATION)
    target_link_libraries(LomiriTestQml ${MOUSETOUCHADAPTOR_LIBS_LDFLAGS})
endif()

# To find libLomiriGestures.so
set_target_properties(LomiriTestQml PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}")

add_lomiri_mock(Lomiri.SelfTest 0.1 Lomiri/SelfTest PREFIX utils TARGETS LomiriTestQml)
