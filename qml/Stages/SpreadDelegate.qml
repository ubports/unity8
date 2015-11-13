/*
 * Copyright 2014-2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 *          Daniel d'Andrada <daniel.dandrada@canonical.com>
 */

import QtQuick 2.4
import QtQuick.Window 2.2
import Ubuntu.Components 1.3
import "../Components"

FocusScope {
    id: root

    // to be read from outside
    readonly property bool dragged: dragArea.moving
    signal clicked()
    signal closed()
    readonly property alias appWindowOrientationAngle: appWindowWithShadow.orientationAngle
    readonly property alias appWindowRotation: appWindowWithShadow.rotation
    readonly property alias orientationChangesEnabled: appWindow.orientationChangesEnabled

    // to be set from outside
    property bool interactive: true
    property bool dropShadow: true
    property real maximizedAppTopMargin
    property alias swipeToCloseEnabled: dragArea.enabled
    property bool closeable
    property alias application: appWindow.application
    property int shellOrientationAngle
    property int shellOrientation
    property QtObject orientations

    function matchShellOrientation() {
        if (!root.application)
            return;
        appWindowWithShadow.orientationAngle = root.shellOrientationAngle;
    }

    function animateToShellOrientation() {
        if (!root.application)
            return;

        if (root.application.rotatesWindowContents) {
            appWindowWithShadow.orientationAngle = root.shellOrientationAngle;
        } else {
            orientationChangeAnimation.start();
        }
    }

    OrientationChangeAnimation {
        id: orientationChangeAnimation
        objectName: "orientationChangeAnimation"
        spreadDelegate: root
        background: background
        window: appWindowWithShadow
        screenshot: appWindowScreenshotWithShadow
    }

    QtObject {
        id: priv
        property bool startingUp: true
    }

    Component.onCompleted: { finishStartUpTimer.start(); }
    Timer { id: finishStartUpTimer; interval: 400; onTriggered: priv.startingUp = false }

    Rectangle {
        id: background
        color: "black"
        anchors.fill: parent
        visible: false
    }

    Item {
        objectName: "displacedAppWindowWithShadow"

        readonly property real limit: root.height / 4

        y: root.closeable ? dragArea.distance : elastic(dragArea.distance)
        width: parent.width
        height: parent.height

        function elastic(distance) {
            var k = distance < 0 ? -limit : limit
            return k * (1 - Math.pow((k - 1) / k, distance))
        }

        Item {
            id: appWindowWithShadow
            objectName: "appWindowWithShadow"

            property int orientationAngle

            property real transformRotationAngle: 0
            property real transformOriginX
            property real transformOriginY

            property var window: appWindow

            transform: Rotation {
                origin.x: appWindowWithShadow.transformOriginX
                origin.y: appWindowWithShadow.transformOriginY
                axis { x: 0; y: 0; z: 1 }
                angle: appWindowWithShadow.transformRotationAngle
            }

            state: {
                if (priv.startingUp) {
                    return "startingUp";
                } else if (root.application && root.application.rotatesWindowContents) {
                    return "counterRotate";
                } else if (orientationChangeAnimation.running) {
                    return "animatingRotation";
                } else  {
                    return "keepSceneRotation";
                }
            }

            // Ensures the given angle is in the form (0,90,180,270)
            function normalizeAngle(angle) {
                while (angle < 0) {
                    angle += 360;
                }
                return angle % 360;
            }

            states: [
                // Sets the initial orientationAngle of the window, when it first slides into view
                // (with the splash screen likely being displayed). At that point we just try to
                // match shell's current orientation. We need a bit of time in this state as the
                // information we need to decide orientationAngle may take a few cycles to
                // be set.
                State {
                    name: "startingUp"
                    PropertyChanges {
                        target: appWindowWithShadow
                        restoreEntryValues: false
                        orientationAngle: {
                            if (!root.application || root.application.rotatesWindowContents) {
                                return 0;
                            }
                            var supportedOrientations = root.application.supportedOrientations;

                            if (supportedOrientations === Qt.PrimaryOrientation) {
                                supportedOrientations = root.orientations.primary;
                            }

                            // If it doesn't support shell's current orientation
                            // then simply pick some arbitraty one that it does support
                            var chosenOrientation = 0;
                            if (supportedOrientations & root.shellOrientation) {
                                chosenOrientation = root.shellOrientation;
                            } else if (supportedOrientations & Qt.PortraitOrientation) {
                                chosenOrientation = root.orientations.portrait;
                            } else if (supportedOrientations & Qt.LandscapeOrientation) {
                                chosenOrientation = root.orientations.landscape;
                            } else if (supportedOrientations & Qt.InvertedPortraitOrientation) {
                                chosenOrientation = root.orientations.invertedPortrait;
                            } else if (supportedOrientations & Qt.InvertedLandscapeOrientation) {
                                chosenOrientation = root.orientations.invertedLandscape;
                            } else {
                                chosenOrientation = root.orientations.primary;
                            }

                            return Screen.angleBetween(root.orientations.native_, chosenOrientation);
                        }

                        rotation: normalizeAngle(appWindowWithShadow.orientationAngle - root.shellOrientationAngle)
                        width: {
                            if (rotation == 0 || rotation == 180) {
                                return root.width;
                            } else {
                                return root.height;
                            }
                        }
                        height: {
                            if (rotation == 0 || rotation == 180)
                                return root.height;
                            else
                                return root.width;
                        }
                    }
                },
                // In this state we stick to our currently set orientationAngle, which may change only due
                // to calls made to matchShellOrientation() or animateToShellOrientation()
                State {
                    id: keepSceneRotationState
                    name: "keepSceneRotation"

                    StateChangeScript { script: {
                        // break binding
                        appWindowWithShadow.orientationAngle = appWindowWithShadow.orientationAngle;
                    } }
                    PropertyChanges {
                        target: appWindowWithShadow
                        restoreEntryValues: false
                        rotation: normalizeAngle(appWindowWithShadow.orientationAngle - root.shellOrientationAngle)
                        width: {
                            if (rotation == 0 || rotation == 180) {
                                return root.width;
                            } else {
                                return root.height;
                            }
                        }
                        height: {
                            if (rotation == 0 || rotation == 180)
                                return root.height;
                            else
                                return root.width;
                        }
                    }
                },
                // In this state we counteract any shell rotation so that the window, in scene coordinates,
                // remains unrotated.
                State {
                    name: "counterRotate"
                    StateChangeScript { script: {
                        // break binding
                        appWindowWithShadow.orientationAngle = appWindowWithShadow.orientationAngle;
                    } }
                    PropertyChanges {
                        target: appWindowWithShadow
                        width: root.shellOrientationAngle == 0 || root.shellOrientationAngle == 180 ? root.width : root.height
                        height: root.shellOrientationAngle == 0 || root.shellOrientationAngle == 180 ? root.height : root.width
                        rotation: normalizeAngle(-root.shellOrientationAngle)
                    }
                    PropertyChanges {
                        target: appWindow
                        surfaceOrientationAngle: orientationAngle
                    }
                },
                State {
                    name: "animatingRotation"
                }
            ]

            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            BorderImage {
                anchors {
                    fill: appWindow
                    margins: -units.gu(2)
                }
                source: "graphics/dropshadow2gu.sci"
                opacity: root.dropShadow ? .3 : 0
                Behavior on opacity { UbuntuNumberAnimation {} }
            }

            ApplicationWindow {
                id: appWindow
                objectName: application ? "appWindow_" + application.appId : "appWindow_null"
                focus: true
                anchors {
                    fill: parent
                    topMargin: appWindow.fullscreen || (application && application.rotatesWindowContents)
                                   ? 0 : maximizedAppTopMargin
                }

                interactive: root.interactive
            }
        }
    }

    Item {
        // mimics appWindowWithShadow. Do the positioning of screenshots of non-fullscreen
        // app windows
        id: appWindowScreenshotWithShadow
        visible: false

        property real transformRotationAngle: 0
        property real transformOriginX
        property real transformOriginY

        transform: Rotation {
            origin.x: appWindowScreenshotWithShadow.transformOriginX
            origin.y: appWindowScreenshotWithShadow.transformOriginY
            axis { x: 0; y: 0; z: 1 }
            angle: appWindowScreenshotWithShadow.transformRotationAngle
        }

        property var window: appWindowScreenshot

        function take() {
            // Format: "image://application/$APP_ID/$CURRENT_TIME_MS"
            // eg: "image://application/calculator-app/123456"
            var timeMs = new Date().getTime();
            appWindowScreenshot.source = "image://application/" + root.application.appId + "/" + timeMs;
        }
        function discard() {
            appWindowScreenshot.source = "";
        }

        Image {
            id: appWindowScreenshot
            source: ""

            anchors.fill: parent

            sourceSize.width: width
            sourceSize.height: height
        }
    }

    DraggingArea {
        id: dragArea
        objectName: "dragArea"
        anchors.fill: parent

        property bool moving: false
        property real distance: 0
        readonly property int threshold: units.gu(2)
        property int offset: 0

        readonly property real minSpeedToClose: units.gu(40)

        onDragValueChanged: {
            if (!dragging) {
                return;
            }
            moving = moving || Math.abs(dragValue) > threshold;
            if (moving) {
                distance = dragValue + offset;
            }
        }

        onMovingChanged: {
            if (moving) {
                offset = (dragValue > 0 ? -threshold: threshold)
            } else {
                offset = 0;
            }
        }

        onClicked: {
            if (!moving) {
                root.clicked();
            }
        }

        onDragEnd: {
            if (!root.closeable) {
                animation.animate("center")
                return;
            }

            // velocity and distance values specified by design prototype
            if ((dragVelocity < -minSpeedToClose && distance < -units.gu(8)) || distance < -root.height / 2) {
                animation.animate("up")
            } else if ((dragVelocity > minSpeedToClose  && distance > units.gu(8)) || distance > root.height / 2) {
                animation.animate("down")
            } else {
                animation.animate("center")
            }
        }

        UbuntuNumberAnimation {
            id: animation
            objectName: "closeAnimation"
            target: dragArea
            property: "distance"
            property bool requestClose: false

            function animate(direction) {
                animation.from = dragArea.distance;
                switch (direction) {
                case "up":
                    animation.to = -root.height * 1.5;
                    requestClose = true;
                    break;
                case "down":
                    animation.to = root.height * 1.5;
                    requestClose = true;
                    break;
                default:
                    animation.to = 0
                }
                animation.start();
            }

            onRunningChanged: {
                if (!running) {
                    dragArea.moving = false;
                    if (requestClose) {
                        root.closed();
                    } else {
                        dragArea.distance = 0;
                    }
                }
            }
        }
    }
}
