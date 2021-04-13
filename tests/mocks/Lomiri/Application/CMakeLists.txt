pkg_check_modules(MIRTEST mirtest>=0.26 REQUIRED)

include_directories(
    SYSTEM
    ${MIRTEST_INCLUDE_DIRS}
    ${MIRAL_INCLUDE_DIRS}
    ${liblomiri-private_SOURCE_DIR}
)

set(FakeLomiriApplicationQml_SOURCES
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

add_library(FakeLomiriApplicationQml MODULE
    ${FakeLomiriApplicationQml_SOURCES}
)

#add_dependencies(FakeLomiriApplicationQml windowmanagementpolicy)

target_link_libraries(FakeLomiriApplicationQml
    ${MIRTEST_LDFLAGS}
    ${MIRAL_LDFLAGS}
    mockwindowmanagmentpolicy
)

add_library(NonMirLomiriApplicationQml MODULE ${FakeLomiriApplicationQml_SOURCES})
set_target_properties(NonMirLomiriApplicationQml PROPERTIES OUTPUT_NAME FakeLomiriApplicationQml)

target_link_libraries(NonMirLomiriApplicationQml
    ${MIRTEST_LDFLAGS}
    ${MIRAL_LDFLAGS}
    mockwindowmanagmentpolicy
    Qt5::Core Qt5::Quick Qt5::DBus
)

target_link_libraries(FakeLomiriApplicationQml Qt5::Core Qt5::Quick Qt5::DBus)

add_lomiri_mock(Lomiri.Application 0.1 Lomiri/Application TARGETS FakeLomiriApplicationQml)
add_lomiri_mock(Lomiri.Application 0.1 Lomiri/Application
                PREFIX nonmirplugins
                TARGETS NonMirLomiriApplicationQml
                BINARY_DIR ${CMAKE_BINARY_DIR}/nonmirplugins
                NO_TYPES)
