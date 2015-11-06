/*
 * Copyright (C) 2015 Canonical, Ltd.
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

import QtQuick 2.4
import QtQuick.Window 2.2
import Unity.Session 0.1
import GSettings 1.0
import "Components"
import "Components/UnityInputInfo"
import "Rotation"
// Backup Workaround https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1473471
// in case we remove the UnityInputInfo import
import Ubuntu.Components 1.3

Rectangle {
    id: root
    color: "black"

    implicitWidth: units.gu(40)
    implicitHeight: units.gu(71)

    DeviceConfiguration {
        id: deviceConfiguration
        name: applicationArguments.deviceName
    }

    property alias orientations: d.orientations

    Item {
        id: d

        property Orientations orientations: Orientations {
            id: orientations
            // NB: native and primary orientations here don't map exactly to their QScreen counterparts
            native_: root.width > root.height ? Qt.LandscapeOrientation : Qt.PortraitOrientation

            primary: deviceConfiguration.primaryOrientation == deviceConfiguration.useNativeOrientation
                ? native_ : deviceConfiguration.primaryOrientation

            landscape: deviceConfiguration.landscapeOrientation
            invertedLandscape: deviceConfiguration.invertedLandscapeOrientation
            portrait: deviceConfiguration.portraitOrientation
            invertedPortrait: deviceConfiguration.invertedPortraitOrientation
        }
    }
        // to be overwritten by tests
    property var unity8Settings: Unity8Settings {}
    property var oskSettings: GSettings { schema.id: "com.canonical.keyboard.maliit" }

    property int physicalOrientation: Screen.orientation
    property bool orientationLocked: OrientationLock.enabled
    property var orientationLock: OrientationLock

    property int orientation
    onPhysicalOrientationChanged: {
        if (!orientationLocked) {
            orientation = physicalOrientation;
        }
    }
    onOrientationLockedChanged: {
        if (orientationLocked) {
            orientationLock.savedOrientation = physicalOrientation;
        } else {
            orientation = physicalOrientation;
        }
    }
    Component.onCompleted: {
        if (orientationLocked) {
            orientation = orientationLock.savedOrientation;
        }
        // We need to manually update this on startup as the binding
        // below doesn't seem to have any effect at that stage
        oskSettings.stayHidden = UnityInputInfo.keyboards > 0
        oskSettings.disableHeight = shell.usageScenario == "desktop"
    }

    // we must rotate to a supported orientation regardless of shell's preference
    property bool orientationChangesEnabled:
        (shell.orientation & supportedOrientations) === 0 ? true
                                                          : shell.orientationChangesEnabled


    Binding {
        target: oskSettings
        property: "stayHidden"
        value: UnityInputInfo.keyboards > 0
    }

    Binding {
        target: oskSettings
        property: "disableHeight"
        value: shell.usageScenario == "desktop"
    }

    readonly property int supportedOrientations: shell.supportedOrientations
        & (deviceConfiguration.supportedOrientations == deviceConfiguration.useNativeOrientation
                ? orientations.native_
                : deviceConfiguration.supportedOrientations)

    property int acceptedOrientationAngle: {
        if (orientation & supportedOrientations) {
            return Screen.angleBetween(orientations.native_, orientation);
        } else if (shell.orientation & supportedOrientations) {
            // stay where we are
            return shell.orientationAngle;
        } else if (angleToOrientation(shell.mainAppWindowOrientationAngle) & supportedOrientations) {
            return shell.mainAppWindowOrientationAngle;
        } else {
            // rotate to some supported orientation as we can't stay where we currently are
            // TODO: Choose the closest to the current one
            if (supportedOrientations & Qt.PortraitOrientation) {
                return Screen.angleBetween(orientations.native_, Qt.PortraitOrientation);
            } else if (supportedOrientations & Qt.LandscapeOrientation) {
                return Screen.angleBetween(orientations.native_, Qt.LandscapeOrientation);
            } else if (supportedOrientations & Qt.InvertedPortraitOrientation) {
                return Screen.angleBetween(orientations.native_, Qt.InvertedPortraitOrientation);
            } else if (supportedOrientations & Qt.InvertedLandscapeOrientation) {
                return Screen.angleBetween(orientations.native_, Qt.InvertedLandscapeOrientation);
            } else {
                // if all fails, fallback to primary orientation
                return Screen.angleBetween(orientations.native_, orientations.primary);
            }
        }
    }

    function angleToOrientation(angle) {
        switch (angle) {
        case 0:
            return orientations.native_;
        case 90:
            return orientations.native_ === Qt.PortraitOrientation ? Qt.InvertedLandscapeOrientation
                                                                : Qt.PortraitOrientation;
        case 180:
            return orientations.native_ === Qt.PortraitOrientation ? Qt.InvertedPortraitOrientation
                                                                : Qt.InvertedLandscapeOrientation;
        case 270:
            return orientations.native_ === Qt.PortraitOrientation ? Qt.LandscapeOrientation
                                                                : Qt.InvertedPortraitOrientation;
        default:
            console.warn("angleToOrientation: Invalid orientation angle: " + angle);
            return orientations.primary;
        }
    }

    RotationStates {
        id: rotationStates
        objectName: "rotationStates"
        orientedShell: root
        shell: shell
        shellCover: shellCover
        windowScreenshot: windowScreenshot
    }

    Shell {
        id: shell
        objectName: "shell"
        width: root.width
        height: root.height
        orientation: root.angleToOrientation(orientationAngle)
        orientations: root.orientations
        nativeWidth: root.width
        nativeHeight: root.height
        mode: applicationArguments.mode
        hasMouse: UnityInputInfo.mice > deviceConfiguration.ignoredMice

        // TODO: Factor in the connected input devices (eg: physical keyboard, mouse, touchscreen),
        //       what's the output device (eg: big TV, desktop monitor, phone display), etc.
        usageScenario: {
            if (root.unity8Settings.usageMode === "Windowed") {
                return "desktop";
            } else if (root.unity8Settings.usageMode === "Staged") {
                if (deviceConfiguration.category === "phone") {
                    return "phone";
                } else {
                    return "tablet";
                }
            } else { // automatic
                if (UnityInputInfo.mice > deviceConfiguration.ignoredMice) {
                    return "desktop";
                } else {
                    return deviceConfiguration.category;
                }
            }
        }

        property real transformRotationAngle
        property real transformOriginX
        property real transformOriginY

        transform: Rotation {
            origin.x: shell.transformOriginX; origin.y: shell.transformOriginY; axis { x: 0; y: 0; z: 1 }
            angle: shell.transformRotationAngle
        }
    }

    Rectangle {
        id: shellCover
        color: "black"
        anchors.fill: parent
        visible: false
    }

    WindowScreenshot {
        id: windowScreenshot
        visible: false
        width: root.width
        height: root.height

        property real transformRotationAngle
        property real transformOriginX
        property real transformOriginY

        transform: Rotation {
            origin.x: windowScreenshot.transformOriginX; origin.y: windowScreenshot.transformOriginY;
            axis { x: 0; y: 0; z: 1 }
            angle: windowScreenshot.transformRotationAngle
        }
    }
}
