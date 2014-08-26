/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 1.1
import "../Components"

Item {
    id: root

    // to be read from outside
    readonly property bool dragged: dragArea.moving
    signal clicked()
    signal closed()

    // to be set from outside
    property bool interactive: true
    property bool dropShadow: true
    property real maximizedAppTopMargin
    property alias swipeToCloseEnabled: dragArea.enabled
    property bool closeable
    property alias application: appWindow.application
    property int orientation

    Item {
        objectName: "appWindowWithShadow"

        y: dragArea.distance
        width: parent.width
        height: parent.height

        BorderImage {
            anchors {
                fill: appWindow
                leftMargin: -units.gu(2)
                rightMargin: -units.gu(2)
                bottomMargin: -units.gu(2)
                topMargin: -units.gu(2)
            }
            source: "graphics/dropshadow.png"
            border { left: 50; right: 50; top: 50; bottom: 50 }
            opacity: root.dropShadow ? .4 : 0
            Behavior on opacity { UbuntuNumberAnimation {} }
        }

        ApplicationWindow {
            id: appWindow
            anchors {
                fill: parent
                topMargin: appWindow.fullscreen ? 0 : maximizedAppTopMargin
            }

            interactive: root.interactive
            orientation: root.orientation
        }
    }

    DraggingArea {
        id: dragArea
        objectName: "dragArea"
        anchors.fill: parent

        property bool moving: false
        property real distance: 0

        readonly property real minSpeedToClose: units.gu(40)

        onDragValueChanged: {
            if (!dragging) {
                return;
            }
            moving = moving || Math.abs(dragValue) > units.gu(1)
            if (moving) {
                distance = dragValue;
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
