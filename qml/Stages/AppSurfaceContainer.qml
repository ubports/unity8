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

SurfaceContainer {
    id: container
    property var promptSurfaces

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
        onTriggered: surfaceContainer.revealSurface()
    }

    Loader {
        z: 3
        id: splashLoader
        anchors.fill: parent
    }

    Repeater {
        model: container.promptSurfaces

        delegate: SurfaceContainer {
            anchors {
                fill: container
                topMargin: container.surface.anchors.topMargin
                rightMargin: container.surface.anchors.rightMargin
                bottomMargin: container.surface.anchors.bottomMargin
                leftMargin: container.surface.anchors.leftMargin
            }

            z: 4 + index
            surface: modelData

            Component.onCompleted: {
                animateIn();
            }
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
}
