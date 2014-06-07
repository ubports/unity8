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

Item {
    id: orientedShell

    // this is only here to select the width / height of the window if not running fullscreen
    //property bool tablet: false
    //width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    //height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

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
                x: 0
                y: 0
                width: orientedShell.height
                height: orientedShell.width
            }
        },
        // FIXME: 180 and 270 need to be updated
        State {
            name: "180"
            PropertyChanges {
                target: shell
                rotation: 180
                x: orientedShell.width
                y: orientedShell.height
                width: orientedShell.width
                height: orientedShell.height
            }
        },
        State {
            name: "270"
            PropertyChanges {
                target: shell
                rotation: 270
                x: 0
                y: orientedShell.height
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
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 0; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: -90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
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
                ParallelAnimation {
                    NumberAnimation { target: shell; property: "opacity"; from: 0; to: 1; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: shell; property: "transformRotationAngle"; to: 90; duration: rotationDuration; easing.type: rotationEasing }

                    NumberAnimation { target: windowScreenshot; property: "opacity"; from: 1; to: 0; duration: rotationDuration; easing.type: rotationEasing }
                    NumberAnimation { target: windowScreenshot; property: "transformRotationAngle"; from: 0; to: 90; duration: rotationDuration; easing.type: rotationEasing }
                }
                PropertyAction { target: windowScreenshot; property: "visible"; value: false }
            }
        }
    ]

    Shell {
        id: shell
        property real transformRotationAngle: 0

        transform: Rotation {
            origin.x: orientedShell.width / 2; origin.y: orientedShell.width / 2; axis { x: 0; y: 0; z: 1 }
            angle: shell.transformRotationAngle
        }
    }

    WindowScreenshot {
        id: windowScreenshot
        visible: false

        property real transformRotationAngle: 0

        transform: Rotation {
            origin.x: orientedShell.width / 2; origin.y: orientedShell.width / 2; axis { x: 0; y: 0; z: 1 }
            angle: windowScreenshot.transformRotationAngle
        }
    }
}
