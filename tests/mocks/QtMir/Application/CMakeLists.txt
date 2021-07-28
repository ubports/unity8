pkg_check_modules(MIRTEST mirtest>=0.26 REQUIRED)

include_directories(
    SYSTEM
    ${MIRTEST_INCLUDE_DIRS}
    ${MIRAL_INCLUDE_DIRS}
    ${liblomiri-private_SOURCE_DIR}
)

set(FakeQtMirApplicationQml_SOURCES
    plugin.cpp
    ApplicationInfo.cpp
    ApplicationManager.cpp
    MirSurface.cpp
    MirSurfaceItem.cpp
    MirSurfaceListModel.cpp
    MirMock.cpp
    ObjectListModel.h
    SurfaceManager.cpp
    VirtualKeyboard.cpp
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceItemInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/SurfaceManagerInterface.h
    resources/surfaces.qrc
)

add_library(FakeQtMirApplicationQml MODULE
    ${FakeQtMirApplicationQml_SOURCES}
)

#add_dependencies(FakeQtMirApplicationQml windowmanagementpolicy)

target_link_libraries(FakeQtMirApplicationQml
    ${MIRTEST_LDFLAGS}
    ${MIRAL_LDFLAGS}
    mockwindowmanagmentpolicy
)

add_library(NonMirQtMirApplicationQml MODULE ${FakeQtMirApplicationQml_SOURCES})
set_target_properties(NonMirQtMirApplicationQml PROPERTIES OUTPUT_NAME FakeQtMirApplicationQml)

target_link_libraries(NonMirQtMirApplicationQml
    ${MIRTEST_LDFLAGS}
    ${MIRAL_LDFLAGS}
    mockwindowmanagmentpolicy
    Qt5::Core Qt5::Quick Qt5::DBus
)

target_link_libraries(FakeQtMirApplicationQml Qt5::Core Qt5::Quick Qt5::DBus)

add_lomiri_mock(QtMir.Application 0.1 QtMir/Application TARGETS FakeQtMirApplicationQml)
add_lomiri_mock(QtMir.Application 0.1 QtMir/Application
                PREFIX nonmirplugins
                TARGETS NonMirQtMirApplicationQml
                BINARY_DIR ${CMAKE_BINARY_DIR}/nonmirplugins
                NO_TYPES)
