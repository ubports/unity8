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
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1 // For TouchGate
import Utils 0.1 // for InputWatcher
import Unity.Application 0.1 // for MirSurfaceItem

FocusScope {
    id: root
    objectName: "surfaceContainer"

    property var surface: null
    property bool hadSurface: false
    property bool interactive
    property int surfaceOrientationAngle: 0
    property string name: surface ? surface.name : ""
    property bool resizeSurface: true

    property int requestedWidth: -1
    property int requestedHeight: -1

    onSurfaceChanged: {
        if (surface) {
            surfaceItem.surface = surface;
            root.hadSurface = false;
        }
    }

    InputWatcher {
        target: surfaceItem
        onTargetPressedChanged: {
            if (targetPressed && root.interactive) {
                root.focus = true;
                root.forceActiveFocus();
            }
        }
    }

    MirSurfaceItem {
        id: surfaceItem
        objectName: "surfaceItem"

        consumesInput: true

        surfaceWidth: {
            if (root.resizeSurface) {
                if (root.requestedWidth >= 0) {
                    return root.requestedWidth;
                } else {
                    return width;
                }
            } else {
                return -1;
            }
        }

        surfaceHeight: {
            if (root.resizeSurface) {
                if (root.requestedHeight >= 0) {
                    return root.requestedHeight;
                } else {
                    return height;
                }
            } else {
                return -1;
            }
        }

        enabled: root.interactive
        focus: true
        antialiasing: !root.interactive
        orientationAngle: root.surfaceOrientationAngle
    }

    // MirSurface size drives SurfaceContainer size
    Binding {
        target: surfaceItem; property: "width"; value: root.surface ? root.surface.size.width : 0
        when: root.requestedWidth >= 0 && root.surface
    }
    Binding {
        target: surfaceItem; property: "height"; value: root.surface ? root.surface.size.height : 0
        when: root.requestedHeight >= 0 && root.surface
    }
    Binding {
        target: root; property: "width"; value: surfaceItem.width
        when: root.requestedWidth >= 0
    }
    Binding {
        target: root; property: "height"; value: surfaceItem.height
        when: root.requestedHeight >= 0
    }

    // SurfaceContainer size drives MirSurface size
    Binding {
        target: surfaceItem; property: "width"; value: root.width
        when: root.requestedWidth < 0
    }
    Binding {
        target: surfaceItem; property: "height"; value: root.height
        when: root.requestedHeight < 0
    }


    TouchGate {
        targetItem: surfaceItem
        anchors.fill: root
        enabled: surfaceItem.enabled
    }

    states: [
        State {
            name: "zombie"
            when: surfaceItem.surface && !surfaceItem.live
        }
    ]
    transitions: [
        Transition {
            from: ""; to: "zombie"
            SequentialAnimation {
                UbuntuNumberAnimation { target: surfaceItem; property: "opacity"; to: 0.0
                                        duration: UbuntuAnimation.BriskDuration }
                PropertyAction { target: surfaceItem; property: "visible"; value: false }
                ScriptAction { script: {
                    surfaceItem.surface = null;
                    root.hadSurface = true;
                } }
            }
        },
        Transition {
            from: "zombie"; to: ""
            ScriptAction { script: {
                surfaceItem.opacity = 1.0;
                surfaceItem.visible = true;
            } }
        }
    ]
}
