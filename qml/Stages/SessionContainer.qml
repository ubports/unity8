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
    id: root
    objectName: "sessionContainer"
    property Item session
    property var children: session ? session.childSessions : 0
    property bool removing: false
    property alias surface: surfaceContainer.surface

    onSessionChanged: {
        if (session) {
            session.parent = root;
            session.z = 1;
            state = "initial"
        }
    }

    SurfaceContainer {
        id: surfaceContainer
        anchors.fill: session
        z: 2;

        surface: session ? session.surface : null
        onSurfaceChanged: {
            root.animateIn(swipeFromBottom);
        }
    }

    Repeater {
        model: root.children

        delegate: Loader {
            objectName: "childDelegate" + index
            anchors {
                fill: root
                topMargin: root.surface.anchors.topMargin
                rightMargin: root.surface.anchors.rightMargin
                bottomMargin: root.surface.anchors.bottomMargin
                leftMargin: root.surface.anchors.leftMargin
            }
            z: 4

            // Only way to do recursive qml items.
            source: Qt.resolvedUrl("SessionContainer.qml")
            onLoaded: {
                item.session = modelData;
            }

            Connections {
                target: modelData
                onRemoved: {
                    item.animateOut();
                }
            }
        }
    }

    function animateIn(animationComponent) {
        var animation = animationComponent.createObject(root, { "session": root.session });
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
            root.state = "initial";
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
            PropertyChanges { target: session; anchors.fill: root }
        }
    ]
}
