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

Item {
    id: container
    property Item surface: null
    property bool removing: false

    onSurfaceChanged: {
        if (surface) {
            surface.parent = container;
            surface.z = 1;
            state = "initial"
        }
    }

    Connections {
        target: surface
        onRemoved: {
            container.removing = true;

            var childSurfaces = surface.childSurfaces;
            for (var i=0; i<childSurfaces.length; i++) {
                childSurfaces[i].removed();
            }

            animateOut();
        }
    }

    Repeater {
        model: surface ? surface.childSurfaces : null

        delegate: Loader {
            z: 2
            anchors {
                fill: container
                topMargin: container.surface.anchors.topMargin
                rightMargin: container.surface.anchors.rightMargin
                bottomMargin: container.surface.anchors.bottomMargin
                leftMargin: container.surface.anchors.leftMargin
            }

            // Only way to do recursive qml items.
            source: Qt.resolvedUrl("SurfaceContainer.qml")
            onLoaded: {
                item.surface = modelData;
                item.animateIn();
            }
        }
    }

    function animateIn() {
        var animation = swipeFromBottom.createObject(container, { "surface": container.surface });
        animation.start();

        var tmp = d.animations;
        tmp.push(animation);
        d.animations = tmp;
    }

    function animateOut() {
        if (d.animations.length > 0) {
            var tmp = d.animations;
            var popped = tmp.pop();
            popped.end();
            d.animations = tmp;
        } else {
            container.state = "initial";
        }
    }

    QtObject {
        id: d
        property var animations: []
        property var currentAnimation: animations.length > 0 ? animations[animations.length-1] : undefined
    }

    Component {
        id: swipeFromBottom
        SwipeFromBottomAnimation {}
    }

    states: [
        State {
            name: "initial"
            PropertyChanges { target: surface; anchors.fill: container }
        }
    ]
}
