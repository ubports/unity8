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
import Mir.Application 0.1
import Ubuntu.Components 1.0
import "../Components"

Item {
    id: root

    signal clicked()
    property bool interactive: true
    property real maximizedAppTopMargin
    property bool isFullscreen: surface !== null && surface.anchors.topMargin == 0
    property bool dropShadow: true

    // FIXME: This really should be invisible to QML code.
    // e.g. Create a SurfaceItem {} in C++ which we just use without any imperative hacks.
    readonly property var surface: model.surface
    onSurfaceChanged: { print("SURFACE!!", model.surface)
        if (surface) {
            if (!priv.appHasCreatedASurface) {
                surface.visible = false; // hide until splash screen removed
                priv.appHasCreatedASurface = true;
            }

            surface.parent = root;
            surface.anchors.fill = root;
            priv.checkFullscreen(surface);
            surface.z = 1;
        }
    }

    QtObject {
        id: priv
        property bool appHasCreatedASurface: false

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
    }

    Timer { //FIXME - need to delay removing splash screen to allow surface resize to complete
        id: surfaceRevealDelay
        interval: 100
        onTriggered: priv.revealSurface()
    }

    Binding {
        target: surface
        property: "enabled"
        value: root.interactive
    }

    Connections {
        target: surface
        onStateChanged: priv.checkFullscreen(surface);
    }

    StateGroup {
        id: appSurfaceState
        states: [
            State {
                name: "noSurfaceYet"
                when: !priv.appHasCreatedASurface
                StateChangeScript {
                    script: {splashLoader.setSource("Splash.qml", { "name": model.name, "image": model.icon }); }
                }
            },
            State {
                name: "hasSurface"
                when: priv.appHasCreatedASurface && (root.surface !== null)
                StateChangeScript { script: { surfaceRevealDelay.start(); } }
            },
            State {
                name: "surfaceLostButAppStillAlive"
                when: priv.appHasCreatedASurface && (root.surface === null)
                // TODO - use app snapshot
            }
        ]
        state: "noSurfaceYet"
    }

    Loader {
        id: splashLoader
        anchors.fill: parent
    }

    BorderImage {
        id: dropShadowImage
        anchors.fill: surface
        anchors.margins: -units.gu(2)
        source: "graphics/dropshadow.png"
        border { left: 50; right: 50; top: 50; bottom: 50 }
        opacity: root.dropShadow ? .4 : 0
        Behavior on opacity { UbuntuNumberAnimation {} }
    }

    MouseArea {
        anchors.fill: parent
        z: 2
        enabled: !root.interactive
        onClicked: {
            root.clicked()
        }
    }
}
