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
    id: root
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
        onTriggered: root.revealSurface()
    }

    Loader {
        id: splashLoader
        anchors.fill: parent
        z: 3
    }

    Repeater {
        id: promptRepeater
        model: root.promptSurfaces

        delegate: SurfaceContainer {
            objectName: "promptDelegate" + index
            id: prompt

            anchors {
                fill: root
                topMargin: root.surface.anchors.topMargin
                rightMargin: root.surface.anchors.rightMargin
                bottomMargin: root.surface.anchors.bottomMargin
                leftMargin: root.surface.anchors.leftMargin
            }
            z: 4 + index

            surface: modelData

            Component.onCompleted: {
                prompt.animateIn(swipeFromBottom);
            }

            Connections {
                target: prompt.surface
                onRemoved: {
                    // remove all prompts after this one.
                    if (index !== promptRepeater.count-1) {
                        var nextSurface = promptRepeater.itemAt(index+1).surface;
                        nextSurface.removed();
                    }

                    prompt.removing = true;
                    prompt.animateOut();
                }
            }

            Component {
                id: swipeFromBottom
                SwipeFromBottomAnimation {}
            }
        }
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
