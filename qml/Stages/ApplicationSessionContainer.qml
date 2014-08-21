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
*/

import QtQuick 2.0
import "Animations"

SessionContainer {
    id: root
    property bool appHasCreatedASurface: false

    onSurfaceChanged: {
        if (surface) {
            if (!appHasCreatedASurface) {
                surface.visible = false; // hide until splash screen removed
                appHasCreatedASurface = true;
            }
        }
    }

    function revealSurface() {
        surface.visible = true;
        splashLoader.source = "";
    }

    Timer { //FIXME - need to delay removing splash screen to allow surface resize to complete
        id: surfaceRevealDelay
        interval: 100
        onTriggered: root.revealSurface()
    }

    Loader {
        id: splashLoader
        anchors.fill: parent
        z: 3
    }

    StateGroup {
        id: appSurfaceState
        states: [
            State {
                name: "noSurfaceYet"
                when: !root.appHasCreatedASurface
                StateChangeScript {
                    script: { splashLoader.setSource("Splash.qml", { "name": model.name, "image": model.icon }); }
                }
            },
            State {
                name: "hasSurface"
                when: root.appHasCreatedASurface && (root.surface !== null)
                StateChangeScript { script: { surfaceRevealDelay.start(); } }
            },
            State {
                name: "surfaceLostButAppStillAlive"
                when: root.appHasCreatedASurface && (root.surface === null)
                // TODO - use app snapshot
            }
        ]
        state: "noSurfaceYet"
    }
}
