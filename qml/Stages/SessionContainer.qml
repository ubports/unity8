/*
 * Copyright 2014-2015 Canonical Ltd.
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

import QtQuick 2.4
import "Animations"

FocusScope {
    id: root
    objectName: "sessionContainer"
    implicitWidth: _surfaceContainer.implicitWidth
    implicitHeight: _surfaceContainer.implicitHeight
    property QtObject session
    readonly property var childSessions: session ? session.childSessions : null
    readonly property alias surface: _surfaceContainer.surface
    property alias interactive: _surfaceContainer.interactive
    property alias surfaceOrientationAngle: _surfaceContainer.surfaceOrientationAngle
    property alias resizeSurface: _surfaceContainer.resizeSurface

    readonly property alias surfaceContainer: _surfaceContainer
    SurfaceContainer {
        id: _surfaceContainer
        anchors.fill: parent
        surface: session ? session.surface : null
    }

    Repeater {
        id: childSessionsRepeater
        model: root.childSessions

        delegate: Loader {
            objectName: "childDelegate" + index
            anchors.fill: surfaceContainer

            // Only way to do recursive qml items.
            source: Qt.resolvedUrl("SessionContainer.qml")

            z: index

            // Since a Loader is a FocusScope, propagate its focus to the loaded Item
            Binding {
                target: item; when: item
                property: "focus"; value: focus
            }

            Binding {
                target: item; when: item
                property: "interactive"; value: index == (childSessionsRepeater.count - 1) && root.interactive
            }

            Binding {
                target: item; when: item
                property: "session"; value: modelData
            }

            Binding {
                target: item; when: item
                property: "width"; value: root.width
            }

            Binding {
                target: item; when: item
                property: "height"; value: root.height
            }
        }
    }

    states: [
        State {
            name: "rootSession"
            when: root.session && !root.session.parentSession
        },

        State {
            name: "childSession"
            when: root.session && root.session.parentSession !== null && root.session.live
                    && !root.session.surface
        },

        State {
            name: "childSessionReady"
            when: root.session && root.session.parentSession !== null && root.session.live
                    && root.session.surface !== null
        },

        State {
            name: "childSessionZombie"
            when: root.session && root.session.parentSession !== null && !root.session.live
        }
    ]

    transitions: [
        Transition {
            to: "childSessionReady"
            ScriptAction { script: { if (!surfaceContainer.hadSurface) { animateIn(swipeFromBottom); } } }
        },
        Transition {
            to: "childSessionZombie"
            ScriptAction { script: { animateOut(); } }
        }
    ]

    function animateIn(component) {
        var animation = component.createObject(root, { "container": root, });
        animation.start();

        var tmp = d.animations;
        tmp.push(animation);
        d.animations = tmp;
    }

    function animateOut() {
        if (d.animations.length > 0) {
            var tmp = d.animations;
            var popped = tmp.pop();
            popped.completed.connect(function() { root.session.release(); } );
            popped.end();
            d.animations = tmp;
        }
    }

    Component {
        id: swipeFromBottom
        SwipeFromBottomAnimation {}
    }

    QtObject {
        id: d
        property var animations: []

        property var focusedChild: {
            if (childSessionsRepeater.count == 0) {
                return _surfaceContainer;
            } else {
                return childSessionsRepeater.itemAt(childSessionsRepeater.count - 1);
            }
        }
        onFocusedChildChanged: {
            focusedChild.focus = true;
        }
    }
}
