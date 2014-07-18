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

Item {
    id: container
    property Item surface: null
    property string animation
    property bool show: false

    onSurfaceChanged: {
        if (surface) {
            surface.parent = container;
            surface.anchors.fill = container;
            surface.z = 1;
        }
    }

    Repeater {
        model: container.surface ? container.surface.childSurfaces : 0

        delegate: Loader {
            z: 2
            anchors.fill: surface

            // Only way to do recursive qml items.
            source: Qt.resolvedUrl("SurfaceContainer.qml")
            onLoaded: {
                item.parent = container.surface;
                item.surface = modelData;
                item.animation = "overlaySwipeBottom"
                item.show = true;
            }
        }
    }

    states: [
        State {
            name: "baseAnimation"
            PropertyChanges { target: surface; anchors.fill: undefined }
        },

        State {
            name: "overlaySwipeBottom-out"
            extend: "baseAnimation"
            when: surface && animation === "overlaySwipeBottom" && !show
            AnchorChanges { target: surface; anchors.top: surface.parent.bottom }
        },
        State {
            name: "overlaySwipeBottom-in"
            extend: "baseAnimation"
            when: surface && animation === "overlaySwipeBottom" && show
            AnchorChanges { target: surface; anchors.top: surface.parent.top }
        }

        // TODO: more animations!
        // Surface needs to stick around so that we can dimiss them with animation.
    ]

    transitions: [
        Transition {
            from:  "overlaySwipeBottom-out"
            to: "overlaySwipeBottom-in"
            SequentialAnimation {
                PropertyAction { target: surface.parent; property: "clip"; value: true}
                AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
                PropertyAction { target: surface.parent; property: "clip"; value: false}
            }
        },
        Transition {
            from: "overlaySwipeBottom-in"
            to:  "overlaySwipeBottom-out"
            SequentialAnimation {
                PropertyAction { target: surface.parent; property: "clip"; value: true}
                AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
                PropertyAction { target: surface; property: "visible"; value: false}
                PropertyAction { target: surface.parent; property: "clip"; value: false}
            }
        }
    ]
}
