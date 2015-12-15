/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import "../../../../qml/Components"
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1

Item {
    id: root
    x: 0
    width: parent.width
    height: parent.height

    property bool shown: true

    signal dragHandleRecognizedGesture(var dragHandle)

    property bool fullyHidden: x == -width || x == width

    function show() {
        shown = true;
        animation.stop();
        animation.to = 0;
        animation.start();
    }

    function hide() {
        shown = false;
        animation.stop();
        animation.to = x > 0 ? width : -width;
        animation.start();
    }

    StandardAnimation {
        id: animation
        target: root
        property: "x"
    }

    Image { source: "../../UnityLogo.png"; anchors.fill: parent }

    DragHandle {
        id: dragHandle
        anchors.fill: parent
        direction: Direction.Horizontal
        maxTotalDragDistance: root.parent.width
        autoCompleteDragThreshold: parent.width / 3

        onDraggingChanged: {
            if (dragging) {
                dragHandleRecognizedGesture(dragHandle);
            }
        }
    }
}
