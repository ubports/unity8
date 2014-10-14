# in order to include Qt's private headers
remove_definitions(-DQT_NO_KEYWORDS)

set(UbuntuGestures_SOURCES
    CandidateInactivityTimer.cpp
    DebugHelpers.cpp
    Timer.cpp
    TouchOwnershipEvent.cpp
    TouchRegistry.cpp
    UnownedTouchEvent.cpp
)

add_definitions(-DUBUNTUGESTURES_LIBRARY)

add_library(UbuntuGestures SHARED ${UbuntuGestures_SOURCES})

qt5_use_modules(UbuntuGestures Core Quick)

# So that Foo.cpp can #include "Foo.moc"
include_directories(${CMAKE_CURRENT_BINARY_DIR})

install(TARGETS UbuntuGestures
        DESTINATION ${SHELL_PRIVATE_LIBDIR})


# There's no cmake var for v8 include path :-/ so create one
LIST(GET Qt5Core_INCLUDE_DIRS 0 QtCoreDir0)
if(${Qt5Core_VERSION_STRING} VERSION_LESS "5.1.0")
    SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/../QtV8/${Qt5Core_VERSION_STRING}/QtV8)
else()
    SET(Qt5V8_PRIVATE_INCLUDE_DIR ${QtCoreDir0}/QtV8/${Qt5Core_VERSION_STRING}/QtV8)
endif()

# DANGER! DANGER! Using Qt's private API!
include_directories(
    ${Qt5Qml_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS}
    ${Qt5V8_PRIVATE_INCLUDE_DIR}
)
