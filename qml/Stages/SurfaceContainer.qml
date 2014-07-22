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
    readonly property alias surfaceArea: _surfaceArea
    property bool removing: false

    onSurfaceChanged: {
        if (surface) {
            surface.parent = container;
            surface.z = 1;
            state = "initial"
        }
    }

    Item {
        id: _surfaceArea
        anchors.fill: parent
    }

    Connections {
        target: surface
        onRemoved: {
            container.removing = true;

            var childSurfaces = surface.childSurfaces;
            for (var i=0; i<childSurfaces.length; i++) {
                childSurfaces[i].removed();
            }

            //if we don't have children, nothing will tell us to animate out, so do it.
            if (childSurfaces.length === 0) {
                animateOut();
            }
            // tell our parent to animate out.
            if (surface.parentSurface) {
                surface.parentSurface.parent.animateOut();
            }
        }
    }

    Repeater {
        model: container.surface ? container.surface.childSurfaces : 0

        delegate: Loader {
            z: 2
            anchors.fill: surfaceArea

            // Only way to do recursive qml items.
            source: Qt.resolvedUrl("SurfaceContainer.qml")
            onLoaded: {
                item.surface = modelData;
                item.animateIn(swipeFromBottom);
                container.animateIn(swipeUp);
            }
        }
    }

    function animateIn(component) {
        var animation = component.createObject(container, { "surface": container.surface, "surfaceArea": container.surfaceArea });
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
    Component {
        id: swipeUp
        SwipeUpAnimation {}
    }

    states: [
        State {
            name: "initial"
            PropertyChanges { target: surface; anchors.fill: surfaceArea }
        }
        // TODO: more animations!
    ]
}
