/*
 * Copyright 2013 Canonical Ltd.
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
import "../../../qml/Components"
import "tst_DragHandle"
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1
import Unity.Test 0.1

/*
  Two blue fullscreen Showables (a vertical and a horizontal one) with red handles you
  can use to drag them away and green handles to drag them in.

  A black vertical line marks the point where a drag needs no forward velocity to
  achieve auto-completion (i.e., get Showable.show() called after touch release).
 */
Rectangle {
    id: root
    color: "darkblue"
    width: units.gu(70)
    height: units.gu(70)

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: true
    }

    property var dragHandle

    property bool stretch: false
    property real hintDisplacement: 0
    property bool bidirectional: false

    Item {
        id: baseItem
        objectName: "baseItem"
        anchors.fill: parent

        Button {
            visible: root.bidirectional && bidirectionalShowable.fullyHidden
            text: "bidirectionalShowable.show()"
            anchors.centerIn: parent
            onClicked: { bidirectionalShowable.show(); }
        }

        BidirectionalShowable {
            id: bidirectionalShowable
            visible: root.bidirectional
            onDragHandleRecognizedGesture: { root.dragHandle = dragHandle }
        }

        VerticalShowable {
            visible: !root.bidirectional
            onDragHandleRecognizedGesture: { root.dragHandle = dragHandle }
            stretch: root.stretch
            hintDisplacement: root.hintDisplacement
        }

        HorizontalShowable {
            visible: !root.bidirectional
            onDragHandleRecognizedGesture: { root.dragHandle = dragHandle }
            stretch: root.stretch
            hintDisplacement: root.hintDisplacement
        }

        // Visually mark drag threshold
        Rectangle {
            color: "black"
            width: 2
            height: parent.height

            visible: dragHandle !== undefined
                  && (dragHandle.direction === Direction.Horizontal || dragHandle.direction === Direction.Rightwards)

            x: {
                if (dragHandle) {
                    dragHandle.edgeDragEvaluator.dragThreshold;
                } else {
                    0
                }
            }
        }
        Rectangle {
            color: "black"
            width: 2
            height: parent.height

            visible: dragHandle !== undefined
                  && (dragHandle.direction === Direction.Horizontal || dragHandle.direction === Direction.Leftwards)

            x: {
                if (dragHandle) {
                    parent.width - dragHandle.edgeDragEvaluator.dragThreshold;
                } else {
                    0
                }
            }
        }
        Rectangle {
            color: "black";
            height: 2
            width: parent.width

            visible: dragHandle !== undefined && Direction.isVertical(dragHandle.direction)

            y: {
                if (dragHandle) {
                    if (dragHandle.direction === Direction.Downwards) {
                        dragHandle.edgeDragEvaluator.dragThreshold;
                    } else {
                        parent.height - dragHandle.edgeDragEvaluator.dragThreshold;
                    }
                } else {
                    0
                }
            }
        }
    }

    // Display velocities
    Rectangle {
        width: childrenRect.width
        height: childrenRect.height
        color: "white"
        opacity: 0.4
        Text {
            id: velocityText
            font.pixelSize: units.gu(2)
            text: {
                if (dragHandle !== undefined) {
                    "Velocity: " + (dragHandle.edgeDragEvaluator.velocity * 1000);
                } else {
                    "Velocity: -";
                }
            }
        }
        Text {
            anchors.top: velocityText.bottom
            font.pixelSize: units.gu(2)
            text: {
                if (dragHandle !== undefined) {
                    "Minimum velocity: " + (dragHandle.edgeDragEvaluator.minVelocity * 1000);
                } else {
                    "Minimum velocity: -";
                }
            }
        }
    }

    Row {
        objectName: "controls"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: units.gu(1)
        spacing: units.gu(1)

        Button {
            text: root.stretch ? "stretch" : "move"
            onClicked: { root.stretch = !root.stretch; }
        }

        Button {
            text: root.hintDisplacement > 0 ? "hint" : "no hint"
            onClicked: {
                if (root.hintDisplacement > 0) {
                    root.hintDisplacement = 0;
                } else {
                    root.hintDisplacement = units.gu(6);
                }
            }
        }

        Button {
            text: "rotation: " + baseItem.rotation
            onClicked: {
                if (baseItem.rotation === 0.0) {
                    baseItem.rotation = 90.0
                } else {
                    baseItem.rotation = 0.0
                }
            }
        }

        Button {
            text: root.bidirectional ? "bidirectional" : "directional"
            onClicked: { root.bidirectional = !root.bidirectional; }
        }
    }
}
