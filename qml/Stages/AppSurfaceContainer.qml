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

import QtQuick 2.2
import Ubuntu.Components 1.1
import "Animations"

SurfaceContainer {
    id: container
    property var promptSurfaces

    property bool appHasCreatedASurface: false
    property real maximizedAppTopMargin

    onSurfaceChanged: {
        if (surface) {
            if (!appHasCreatedASurface) {
                surface.visible = false; // hide until splash screen removed
                appHasCreatedASurface = true;
            }
        }
    }

    function revealSurface() {
        revealAnimation.start();
    }

    SequentialAnimation {
        id: revealAnimation

        PropertyAction {
            target: surface
            property: "opacity"
            value: 0.0
        }
        PropertyAction {
            target: surface
            property: "visible"
            value: true
        }
        OpacityAnimator {
            duration: UbuntuAnimation.FastDuration
            easing: UbuntuAnimation.StandardEasing
            target: surface
            from: 0.0
            to: 1.0
        }
        PropertyAction {
            target: splashLoader
            property: "source"
            value: ""
        }
    }

    Timer { //FIXME - need to delay removing splash screen to allow surface resize to complete
        id: surfaceRevealDelay
        interval: 400
        onTriggered: surfaceContainer.revealSurface()
    }

    Loader {
        id: splashLoader
        anchors.fill: parent
        anchors.topMargin: maximizedAppTopMargin
        z: 0 // so that it is under the surface
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
                    script: {
                        var properties = { "title": model.splashTitle ? model.splashTitle : model.name,
                                           "image": model.splashImage,
                                           "showHeader": model.splashShowHeader
                                         };

                        if (model.splashColor.a == 1) {
                            properties["backgroundColor"] = model.splashColor;
                        }
                        if (model.splashColorHeader.a == 1) {
                            properties["headerColor"] = model.splashColorHeader;
                        }
                        if (model.splashColorFooter.a == 1) {
                            properties["footerColor"] = model.splashColorFooter;
                        }
                        splashLoader.setSource("Splash.qml", properties);
                    }
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
