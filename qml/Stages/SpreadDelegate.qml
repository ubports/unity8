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

Item {
    id: root

    signal clicked()
    property real topMarginProgress
    property bool interactive: true
    property int orientationAngle

    // FIXME: This really should be invisible to QML code.
    // e.g. Create a SurfaceItem {} in C++ which we just use without any imperative hacks.
    property var surface
    onSurfaceChanged: {
        if (surface) {
            surface.parent = root;
            surface.enabled = root.interactive;
            surface.z = 1;

            // for the counter-rotation
            surface.transformOrigin = Item.TopLeft;
        }
    }

    // Applications already rotate automatically. And so does the shell
    // Therefore we have to counter-rotate the app item to undo the rotation applied to
    // it by the shell
    state: orientationAngle.toString()
    states: [
        State {
            name: "0"
            PropertyChanges {
                target: surface
                rotation: 0
                x: 0
                y: 0
                width: root.width
                height: root.height
            }
        },
        State {
            name: "90"
            PropertyChanges {
                target: surface
                rotation: -90
                x: 0
                y: root.height
                width: root.height
                height: root.width
            }
        },
        State {
            name: "180"
            PropertyChanges {
                target: surface
                rotation: -180
                x: root.width
                y: root.height
                width: root.width
                height: root.height
            }
        },
        State {
            name: "270"
            PropertyChanges {
                target: surface
                rotation: -270
                x: root.width
                y: 0
                width: root.height
                height: root.width
            }
        }
    ]

    Component.onDestruction: {
        if (surface) {
            surface.release();
        }
    }

    BorderImage {
        id: dropShadow
        anchors.fill: root
        anchors.margins: -units.gu(2)
        source: "graphics/dropshadow.png"
        opacity: .4
        border { left: 50; right: 50; top: 50; bottom: 50 }
    }

    // This is used to get clicked events on the whole app. e.g. when in spreadView.
    // It's only enabled when the surface is !interactive
    MouseArea {
        anchors.fill: parent
        z: 2
        enabled: !root.interactive
        onClicked: {
            root.clicked()
        }
    }
}
