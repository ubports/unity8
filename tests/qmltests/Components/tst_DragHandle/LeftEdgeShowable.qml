/*
 * Copyright (C) 2013 Canonical, Ltd.
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

Showable {
    id: showable
    x: stretch ? 0 : -width
    width: stretch ? 0 : parent.width
    height: parent.height

    property bool stretch
    property real hintDisplacement

    onStretchChanged: {
        if (stretch) {
            x = 0;
            width = 0;
        } else {
            x = -parent.width;
            width = parent.width;
        }
    }

    shown: false

    signal dragHandleRecognizedGesture(var dragHandle)

    property string animatedProp: stretch ? "width" : "x"
    property real propValueWhenShown: stretch ? parent.width : 0
    property real propValueWhenHidden: stretch ? 0 : -width

    showAnimation: StandardAnimation { property: animatedProp; to: propValueWhenShown }
    hideAnimation: StandardAnimation { property: animatedProp; to: propValueWhenHidden }

    Image { source: "../../UnityLogo.png"; anchors.fill: parent }

    DragHandle {
        objectName: "leftwardsDragHandle"
        id: leftwardsDragHandle
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        width: units.gu(2)

        direction: Direction.Leftwards
        stretch: showable.stretch
        maxTotalDragDistance: showable.parent.width
        hintDisplacement: showable.hintDisplacement

        onDraggingChanged: {
            if (dragging) {
                dragHandleRecognizedGesture(leftwardsDragHandle);
            }
        }

        Rectangle { color: "red"; anchors.fill: parent }
    }

    DragHandle {
        objectName: "rightwardsDragHandle"
        id: rightwardsDragHandle
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.right

        width: units.gu(2)

        direction: Direction.Rightwards
        stretch: showable.stretch
        maxTotalDragDistance: showable.parent.width
        hintDisplacement: showable.hintDisplacement

        onDraggingChanged: {
            if (dragging) {
                dragHandleRecognizedGesture(rightwardsDragHandle);
            }
        }

        Rectangle { color: "green"; anchors.fill: parent }
    }

}
