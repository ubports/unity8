/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Application 0.1

FocusScope {
    id: root

    property alias surface: childWindow.surface
    property real displacementX: 0
    property real displacementY: 0
    property alias boundsItem: childWindow.boundsItem
    property alias decorationHeight: childWindow.decorationHeight

    x: surface ? surface.position.x + displacementX : 0
    y: surface ? surface.position.y + displacementY : 0
    width: childWindow.width
    height: childWindow.height

    ////
    // API expected by MoveHandler (and some by WindowResizeArea as well)
    readonly property bool maximized: false
    readonly property bool maximizedLeft: false
    readonly property bool maximizedRight: false
    readonly property bool maximizedHorizontally: false
    readonly property bool maximizedVertically: false
    readonly property bool maximizedTopLeft: false
    readonly property bool maximizedTopRight: false
    readonly property bool maximizedBottomLeft: false
    readonly property bool maximizedBottomRight: false
    readonly property bool anyMaximized: maximized || maximizedLeft || maximizedRight || maximizedHorizontally || maximizedVertically ||
                                         maximizedTopLeft || maximizedTopRight || maximizedBottomLeft || maximizedBottomRight

    readonly property bool canBeCornerMaximized: false
    readonly property bool canBeMaximizedLeftRight: false
    readonly property bool canBeMaximized: false

    readonly property var resizeArea: QtObject {
        property real normalWidth: units.gu(1)
        property real normalHeight: units.gu(1)
    }

    readonly property bool windowedTransitionRunning: false

    // NB: those bindings will be overwritten by MoveHandler when you first move the window
    property real windowedX: x
    property real windowedY: y

    state: "restored"
    // end of API expected by MoveHandler
    ////

    ////
    // API expected by WindowResizeArea
    property real windowedWidth: childWindow.width
    property real windowedHeight: childWindow.height
    // end of API expected by WindowResizeArea
    ////

    ////
    // API expected by WindowControlsOverlay
    function activate() {
        surface.activate();
    }
    // end of API expected by WindowControlsOverlay
    ////

    Binding {
        target: root.surface
        when: childWindow.dragging
        property: "requestedPosition"
        value: Qt.point(root.windowedX - root.displacementX,
                        root.windowedY - root.displacementY);
    }

    // It's a separate Item so that a window can be hid independently of its children
    ChildWindow {
        id: childWindow
        target: root
        requestedWidth: root.windowedWidth
        requestedHeight: root.windowedHeight
    }

    Connections {
        target: root.surface
        onFocusRequested: {
            root.surface.activate();
        }
        onFocusedChanged: {
            if (root.surface.focused) {
                childWindow.focus = true;
                // Propagate
                root.focus = true;
            }
        }
    }

    // Using a loader here mainly to circunvent the "ChildWindowTree is instantiated recursively" error from the QML engine
    Loader {
        id: childRepeaterLoader
        source: "ChildWindowRepeater.qml"
        active: root.surface && root.surface.childSurfaceList.count > 0
        Binding {
            target: childRepeaterLoader.item
            when: childRepeaterLoader.item
            property: "model"
            value: root.surface ? root.surface.childSurfaceList : null
        }
        Binding {
            target: childRepeaterLoader.item
            when: childRepeaterLoader.item
            property: "boundsItem"
            value: root.boundsItem
        }
        onFocusChanged: {
            if (focus) {
                // A surface in some ChildWindowTree got focused.
                // Propagate
                root.focus = true;
            }
        }
    }
}
