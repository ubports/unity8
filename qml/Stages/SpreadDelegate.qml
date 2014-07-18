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
*/

import QtQuick 2.0
import Unity.Application 0.1
import Ubuntu.Components 1.1
import "../Components"

Item {
    id: root

    // to be set from outside
    property bool interactive: true
    property bool dropShadow: true
    property real maximizedAppTopMargin
    property alias swipeToCloseEnabled: dragArea.enabled

    readonly property bool isFullscreen: surface !== null && surfaceContainer.surface.anchors.topMargin == 0

    signal clicked()
    signal closed()

    Item {
        id: surfaceContainer
        anchors.fill: parent
        readonly property var surface: model.surface
        property bool appHasCreatedASurface: false

        onSurfaceChanged: {
            if (surface) {
                if (!appHasCreatedASurface) {
                    surface.visible = false; // hide until splash screen removed
                    appHasCreatedASurface = true;
                }

                surface.parent = surfaceContainer;
                surface.anchors.fill = surfaceContainer;
                surfaceContainer.checkFullscreen(surface);
                surface.z = 1;
            }
        }

        function checkFullscreen(surface) {
            if (surface.state === MirSurfaceItem.Fullscreen) {
                surface.anchors.topMargin = 0;
            } else {
                surface.anchors.topMargin = maximizedAppTopMargin;
            }
        }

        function revealSurface() {
            surface.visible = true;
            splashLoader.source = "";
        }

        Binding {
            target: surface
            property: "enabled"
            value: root.interactive
        }
        Binding {
            target: surface
            property: "focus"
            value: root.interactive
        }

        Timer { //FIXME - need to delay removing splash screen to allow surface resize to complete
            id: surfaceRevealDelay
            interval: 100
            onTriggered: surfaceContainer.revealSurface()
        }

        Connections {
            target: surface
            onStateChanged: surfaceContainer.checkFullscreen(surface);
            // FIXME: I would rather not need to do this, but currently it doesn't get
            // active focus without it and I don't know why.
            onFocusChanged: forceSurfaceActiveFocusIfReady();
            onParentChanged: forceSurfaceActiveFocusIfReady();
            onEnabledChanged: forceSurfaceActiveFocusIfReady();
            function forceSurfaceActiveFocusIfReady() {
                if (surface.focus && surface.parent === surfaceContainer && surface.enabled) {
                    surface.forceActiveFocus();
                }
            }
        }

        BorderImage {
            id: dropShadowImage
            anchors {
                fill: parent
                leftMargin: -units.gu(2)
                rightMargin: -units.gu(2)
                bottomMargin: -units.gu(2)
                topMargin: -units.gu(2) + (root.isFullscreen ? 0 : maximizedAppTopMargin)
            }
            source: "graphics/dropshadow.png"
            border { left: 50; right: 50; top: 50; bottom: 50 }
            opacity: root.dropShadow ? .4 : 0
            Behavior on opacity { UbuntuNumberAnimation {} }
        }

        transform: Translate {
            y: dragArea.distance
        }
    }


    StateGroup {
        id: appSurfaceState
        states: [
            State {
                name: "noSurfaceYet"
                when: !surfaceContainer.appHasCreatedASurface
                StateChangeScript {
                    script: { splashLoader.setSource("Splash.qml", { "name": model.name, "image": model.icon }); }
                }
            },
            State {
                name: "hasSurface"
                when: surfaceContainer.appHasCreatedASurface && (surfaceContainer.surface !== null)
                StateChangeScript { script: { surfaceRevealDelay.start(); } }
            },
            State {
                name: "surfaceLostButAppStillAlive"
                when: surfaceContainer.appHasCreatedASurface && (surfaceContainer.surface === null)
                // TODO - use app snapshot
            }
        ]
        state: "noSurfaceYet"
    }

    Loader {
        id: splashLoader
        anchors.fill: surfaceContainer
    }

    DraggingArea {
        id: dragArea
        anchors.fill: parent

        property bool moving: false
        property real distance: 0

        onMovingChanged: {
            spreadView.draggedIndex = moving ? index : -1
        }

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
            // velocity and distance values specified by design prototype
            if ((dragVelocity < -units.gu(40) && distance < -units.gu(8)) || distance < -root.height / 2) {
                animation.animate("up")
            } else if ((dragVelocity > units.gu(40) && distance > units.gu(8)) || distance > root.height / 2) {
                animation.animate("down")
            } else {
                animation.animate("center")
            }
        }

        UbuntuNumberAnimation {
            id: animation
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
                    dragArea.distance = 0;
                    if (requestClose) {
                        root.closed();
                    }
                }
            }
        }
    }
}
