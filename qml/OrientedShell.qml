/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Window 2.0
import Ubuntu.Components 0.1
import "Components"

Rectangle {
    // white background when dash is shown to better match Dashes own background, making for
    // a nicer rotation animation effect. If gives the illusion that the dash is always taking the entire
    // screen during the rotation.
    color: shell.dashShown ? "white" : "black"
    id: orientedShell

    // this is only here to select the width / height of the window if not running fullscreen
    //property bool tablet: false
    //width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    //height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

    // Hack to avoid animating during startup
    property bool ready: false
    Timer { id: readyTimer; interval: 50; onTriggered: ready = true }
    Component.onCompleted: readyTimer.start()

    property int acceptedOrientationAngle: {
        var screenOrientation = Screen.orientation;
        var acceptedOrientation;

        if (screenOrientation & shell.supportedScreenOrientations) {
            acceptedOrientation = screenOrientation;
        } else {
            // try orientations at -90, 90 and 180
            switch (screenOrientation) {
            case Qt.PortraitOrientation:
                if (Qt.LandscapeOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.LandscapeOrientation;
                } else if (Qt.InvertedLandscapeOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.InvertedLandscapeOrientation;
                } else {
                    acceptedOrientation = Qt.InvertedPortraitOrientation;
                }
                break;
            case Qt.InvertedPortraitOrientation:
                if (Qt.LandscapeOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.LandscapeOrientation;
                } else if (Qt.InvertedLandscapeOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.InvertedLandscapeOrientation;
                } else {
                    acceptedOrientation = Qt.PortraitOrientation;
                }
                break;
            case Qt.LandscapeOrientation:
                if (Qt.PortraitOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.PortraitOrientation;
                } else if (Qt.InvertedPortraitOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.InvertedPortraitOrientation;
                } else {
                    acceptedOrientation = Qt.InvertedLandscapeOrientation;
                }
                break;
            default: // Qt.InvertedLandscapeOrientation
                if (Qt.PortraitOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.PortraitOrientation;
                } else if (Qt.InvertedPortraitOrientation & shell.supportedScreenOrientations) {
                    acceptedOrientation = Qt.InvertedPortraitOrientation;
                } else {
                    acceptedOrientation = Qt.LandscapeOrientation;
                }
                break;
            }
        }

        return Screen.angleBetween(Screen.primaryOrientation, acceptedOrientation);
    }

    state: acceptedOrientationAngle.toString()
    states: [
        State {
            name: "0"
            PropertyChanges {
                target: shell
                transformRotationAngle: 0
                transformOriginX: orientedShell.width / 2
                transformOriginY: orientedShell.width / 2
                x: 0
                y: 0
                width: orientedShell.width
                height: orientedShell.height
            }
        },
        State {
            name: "90"
            PropertyChanges {
                target: shell
                transformRotationAngle: 90
                transformOriginX: orientedShell.width / 2
                transformOriginY: orientedShell.width / 2
                x: 0
                y: 0
                width: orientedShell.height
                height: orientedShell.width
            }
        },
        State {
            name: "180"
            PropertyChanges {
                target: shell
                transformRotationAngle: 180
                transformOriginX: orientedShell.width / 2
                transformOriginY: orientedShell.width / 2
                x: 0
                y: orientedShell.height - orientedShell.width
                width: orientedShell.width
                height: orientedShell.height
            }
        },
        State {
            name: "270"
            PropertyChanges {
                target: shell
                transformRotationAngle: -90
                transformOriginX: orientedShell.height / 2
                transformOriginY: orientedShell.height / 2
                x: 0
                y: 0
                width: orientedShell.height
                height: orientedShell.width
            }
        }
    ]


    property int rotationDuration: 450
    property int rotationEasing: Easing.InOutCubic
    // Those values are good for debugging/development
    //property int rotationDuration: 6000
    //property int rotationEasing: Easing.Linear

    transitions: [
        Transition {
            from: "90"
            to: "0"
            enabled: ready
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.width }
                PropertyAction { target: shell; property: "height"; value: orientedShell.height }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: 90 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 0; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: -90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "0"
            to: "90"
            enabled: ready
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.height }
                PropertyAction { target: shell; property: "height"; value: orientedShell.width }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: 0 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 90; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: 90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "0"
            to: "270"
            enabled: ready
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.height }
                PropertyAction { target: shell; property: "height"; value: orientedShell.width }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: 0 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.height / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.height / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.height / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.height / 2 }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: -90; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: -90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "270"
            to: "0"
            enabled: ready
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.width }
                PropertyAction { target: shell; property: "height"; value: orientedShell.height }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: -90 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.height / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.height / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.height / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.height / 2 }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 0; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: 90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "90"
            to: "180"
            enabled: true
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.width }
                PropertyAction { target: shell; property: "height"; value: orientedShell.height }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: 90 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 180; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "y"; from: 0; to: orientedShell.height - orientedShell.width; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: 90; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "y"; from: 0; to: orientedShell.height - orientedShell.width; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "180"
            to: "90"
            enabled: true
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.height }
                PropertyAction { target: shell; property: "height"; value: orientedShell.width }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: 180 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.height - (orientedShell.width / 2) }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 90; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "y"; from: orientedShell.height - orientedShell.width; to: 0; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: -90; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "y"; from: 0; to: -orientedShell.height + orientedShell.width; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "180"
            to: "270"
            enabled: true
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.height }
                PropertyAction { target: shell; property: "height"; value: orientedShell.width }
                PropertyAction { target: shell; property: "y"; value: orientedShell.height - orientedShell.width }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: 180 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.height - (orientedShell.width / 2) }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 270; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: 90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "270"
            to: "180"
            enabled: ready
            SequentialAnimation {
                ScriptAction { script: { windowScreenshot.take(); } }
                PropertyAction { target: windowScreenshot; property: "visible"; value: true }
                PropertyAction { target: shell; property: "width"; value: orientedShell.width }
                PropertyAction { target: shell; property: "height"; value: orientedShell.height }
                PropertyAction { target: shell; property: "y"; value: orientedShell.height - orientedShell.width }
                PropertyAction { target: shell; property: "transformRotationAngle"; value: 270 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: windowScreenshot; property: "transformOriginY"; value: orientedShell.height - (orientedShell.width / 2) }
                PropertyAction { target: windowScreenshot; property: "y"; value: 0 }
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 180; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: -90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
                ScriptAction { script: { windowScreenshot.discard(); } }
            }
        },
        Transition {
            from: "0"
            to: "180"
            enabled: ready
            SequentialAnimation {
                PropertyAction { target: shell; property: "y"; value: 0 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.height / 2 }

                NumberAnimation { target: shell; property: "transformRotationAngle"; from: 0; to: 180; duration: rotationDuration; easing.type: rotationEasing }
            }
        },
        Transition {
            from: "180"
            to: "0"
            enabled: ready
            SequentialAnimation {
                PropertyAction { target: shell; property: "y"; value: 0 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.height / 2 }

                NumberAnimation { target: shell; property: "transformRotationAngle"; from: 180; to: 0; duration: rotationDuration; easing.type: rotationEasing }
            }
        },
        Transition {
            from: "90"
            to: "270"
            enabled: ready
            SequentialAnimation {
                PropertyAction { target: shell; property: "x"; value: -(orientedShell.height - orientedShell.width) / 2 }
                PropertyAction { target: shell; property: "y"; value: (orientedShell.height - orientedShell.width) / 2 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.height / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }

                NumberAnimation { target: shell; property: "transformRotationAngle"; from: 90; to: 270; duration: rotationDuration; easing.type: rotationEasing }

                // Explicitly apply state "270" values as Qt doesn't seem to properly apply them after the transition is done
                PropertyAction { target: shell; property: "x"; value: 0 }
                PropertyAction { target: shell; property: "y"; value: 0 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.height / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.height / 2 }
            }
        },
        Transition {
            from: "270"
            to: "90"
            enabled: ready
            SequentialAnimation {
                PropertyAction { target: shell; property: "x"; value: -(orientedShell.height - orientedShell.width) / 2 }
                PropertyAction { target: shell; property: "y"; value: (orientedShell.height - orientedShell.width) / 2 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.height / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }

                NumberAnimation { target: shell; property: "transformRotationAngle"; from: 270; to: 90; duration: rotationDuration; easing.type: rotationEasing }

                // Explicitly apply state "90" values as Qt doesn't seem to properly apply them after the transition is done
                PropertyAction { target: shell; property: "x"; value: 0 }
                PropertyAction { target: shell; property: "y"; value: 0 }
                PropertyAction { target: shell; property: "transformOriginX"; value: orientedShell.width / 2 }
                PropertyAction { target: shell; property: "transformOriginY"; value: orientedShell.width / 2 }
            }
        }
    ]

    Shell {
        id: shell
        property real transformRotationAngle
        property real transformOriginX
        property real transformOriginY

        transform: Rotation {
            origin.x: shell.transformOriginX; origin.y: shell.transformOriginY; axis { x: 0; y: 0; z: 1 }
            angle: shell.transformRotationAngle
        }
    }

    WindowScreenshot {
        id: windowScreenshot
        visible: false
        width: orientedShell.width
        height: orientedShell.height

        property real transformRotationAngle
        property real transformOriginX
        property real transformOriginY

        transform: Rotation {
            origin.x: windowScreenshot.transformOriginX; origin.y: windowScreenshot.transformOriginY; axis { x: 0; y: 0; z: 1 }
            angle: windowScreenshot.transformRotationAngle
        }
    }
}
