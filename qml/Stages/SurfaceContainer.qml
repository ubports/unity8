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
            if (surface.parentSurface) {
                surface.parentSurface.parent.animateOut();
            }
            container.removing = true;
            animateOut();
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
                item.animateIn("swipeFromBottom");
                container.animateIn("swipeUp");
            }
        }
    }

    function animateIn(type) {
        var tmp = d.animations;
        tmp.push(type);
        d.animations = tmp;

        container.state = d.currentAnimation + "-prep";
        container.state = d.currentAnimation + "-in";
    }

    function animateOut() {
        if (d.animations.length > 0) {
            var tmp = d.animations;
            var popped = tmp.pop();
            d.animations = tmp;
            container.state = popped + "-out";
            if (d.currentAnimation !== "") {
                container.state = d.currentAnimation + "-in";
            }
        } else {
            container.state = "initial";
        }
    }

    QtObject {
        id: d
        property variant animations: []
        property string currentAnimation: animations.length > 0 ? animations[animations.length-1] : ""
    }

    states: [
        State {
            name: "initial"
            PropertyChanges { target: surface; anchors.fill: surfaceArea }
        },

        State {
            name: "baseAnimation"
            PropertyChanges { target: surface; anchors.fill: undefined }
        },

        State {
            name: "swipeFromBottom-prep"
            extend: "baseAnimation"
            AnchorChanges { target: surface; anchors.top: surfaceArea.bottom }
        },
        State {
            name: "swipeFromBottom-out"
            extend: "swipeFromBottom-prep"
        },
        State {
            name: "swipeFromBottom-in"
            extend: "baseAnimation"
            AnchorChanges { target: surface; anchors.top: surfaceArea.top }
        },

        State {
            name: "swipeUp-prep"
            extend: "baseAnimation"
        },
        State {
            name: "swipeUp-out"
            extend: "swipeUp-prep"
        },
        State {
            name: "swipeUp-in"
            extend: "baseAnimation"
            AnchorChanges { target: surface; anchors.bottom: surfaceArea.top }
        }
        // TODO: more animations!
    ]

    transitions: [
        Transition {
            to: "swipeFromBottom-in"
            SequentialAnimation {
                PropertyAction { target: surface.parent; property: "clip"; value: true }
                AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
                PropertyAction { target: surface.parent; property: "clip"; value: false }
            }
        },
        Transition {
            to:  "swipeFromBottom-out"
            SequentialAnimation {
                PropertyAction { target: surface.parent; property: "clip"; value: true }
                AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
                PropertyAction { target: surface; property: "visible"; value: !removing }
                PropertyAction { target: surface.parent; property: "clip"; value: false }
                ScriptAction { script: { if (container.removing) surface.release() } }
            }
        },

        Transition {
            to: "swipeUp-in"
            SequentialAnimation {
                PropertyAction { target: surface.parent; property: "clip"; value: true }
                AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
                PropertyAction { target: surface; property: "visible"; value: false}
                PropertyAction { target: surface.parent; property: "clip"; value: false }
            }
        },
        Transition {
            to:  "swipeUp-out"
            SequentialAnimation {
                PropertyAction { target: surface.parent; property: "clip"; value: true }
                PropertyAction { target: surface; property: "visible"; value: true }
                AnchorAnimation { easing.type: Easing.InOutQuad; duration: 400 }
                PropertyAction { target: surface.parent; property: "clip"; value: false }
                ScriptAction { script: { if (container.removing) surface.release() } }
            }
        }
    ]
}
