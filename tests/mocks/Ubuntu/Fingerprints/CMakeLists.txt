set(MOCK_FINGERPRINTS_SOURCES
    plugin.cpp
    MockFingerprints.cpp
)

add_library(MockFingerprints MODULE ${MOCK_FINGERPRINTS_SOURCES})

qt5_use_modules(MockFingerprints Qml Quick Core)

add_unity8_mock(Ubuntu.Fingerprints 0.1 Ubuntu/Fingerprints TARGETS MockFingerprints)
