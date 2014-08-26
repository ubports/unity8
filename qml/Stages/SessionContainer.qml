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
    property var childSessions: session ? session.childSessions : 0
    property bool removing: false
    property alias surface: surfaceContainer.surface
    property bool interactive: true

    onSessionChanged: {
        if (session) {
            session.parent = root;
            session.z = 1;
        }
    }

    SurfaceContainer {
        id: surfaceContainer
        anchors.fill: parent
        z: 2;

        surface: session ? session.surface : null
        onSurfaceChanged: {
//            root.animateIn(swipeFromBottom);
        }
    }

    Binding {
        target: surface
        when: surface
        property: "enabled"
        value: interactive
    }
    Binding {
        target: surface
        when: surface
        property: "focus"
        value: interactive
    }

    Repeater {
        model: root.childSessions

        delegate: Loader {
            objectName: "childDelegate" + index
            anchors.fill: surfaceContainer
            z: 4

            // Only way to do recursive qml items.
            source: Qt.resolvedUrl("SessionContainer.qml")
            onLoaded: {
                item.session = modelData;
                item.interactive = Qt.bindind(function() { return root.interactive; } );
            }

            Connections {
                target: modelData
                onRemoved: {
                    item.removing = true;
//                    item.animateOut();
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
}
