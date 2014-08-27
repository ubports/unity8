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
    property QtObject session
    property var childSessions: session ? session.childSessions : 0
    property bool removing: false
    property alias surface: _surfaceContainer.surface
    property bool interactive: true

    onSessionChanged: {
        if (session) {
            session.parent = root;
            session.z = 1;
        }
    }

    readonly property alias surfaceContainer: _surfaceContainer
    SurfaceContainer {
        id: _surfaceContainer
        anchors.fill: parent
        z: 2
        surface: session ? session.surface : null
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
                item.interactive = Qt.binding(function() { return root.interactive; } );
            }

            Connections {
                target: modelData
                onSurfaceChanged: {
                    item.animateIn(swipeFromBottom);
                }
                onRemoved: {
                    item.removing = true;
                    item.animateOut();
                }
            }

            Component {
                id: swipeFromBottom
                SwipeFromBottomAnimation {}
            }
        }
    }

    function animateIn(animationComponent) {
        var animation = animationComponent.createObject(root,
                                                        {
                                                            "sessionContainer": root,
                                                            "surfaceContainer": surfaceContainer
                                                        });
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
}
