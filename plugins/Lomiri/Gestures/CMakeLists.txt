# in order to include Qt's private headers
remove_definitions(-DQT_NO_KEYWORDS)

set(LomiriGesturesQml_SOURCES
    plugin.cpp
    AxisVelocityCalculator.cpp
    Direction.cpp
    MouseEventGenerator.cpp
    PressedOutsideNotifier.cpp
    TouchDispatcher.cpp
    TouchGate.cpp
    TouchGestureArea.cpp
)

pkg_check_modules(LOMIRIGESTURES REQUIRED LomiriGestures)

add_definitions(-DLOMIRIGESTURESQML_LIBRARY)

add_library(LomiriGesturesQml SHARED ${LomiriGesturesQml_SOURCES})
target_link_libraries(LomiriGesturesQml ${LOMIRIGESTURES_LIBRARIES} Qt5::Core Qt5::Quick)

# So that Foo.cpp can #include "Foo.moc"
include_directories(${CMAKE_CURRENT_BINARY_DIR})

include_directories(
    SYSTEM
    ${LOMIRIGESTURES_INCLUDE_DIRS}
    ${LOMIRIGESTURES_INCLUDEDIR}/LomiriGestures/${LOMIRIGESTURES_VERSION}
)

# There's no cmake var for v8 include path :-/ so create one
LIST(GET Qt5Core_INCLUDE_DIRS 0 QtCoreDir0)
SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/QtV8/${Qt5Core_VERSION_STRING}/QtV8)

# DANGER! DANGER! Using Qt's private API!
include_directories(
    SYSTEM
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${Qt5V8_PRIVATE_INCLUDE_DIR}
)

add_unity8_plugin(Lomiri.Gestures 0.1 Lomiri/Gestures TARGETS LomiriGesturesQml)
