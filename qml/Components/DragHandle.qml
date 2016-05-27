/*
 * Copyright (C) 2013,2016 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1

/*
 Put a DragHandle inside a Showable to enable the user to drag it from that handle.
 Main use case is to drag fullscreen Showables into the screen or off the screen.

 This example shows a DragHandle placed on the right corner of a Showable, used
 to slide it away, off the screen.

  Showable {
    x: 0
    y: 0
    width: ... // screen width
    height: ... // screen height
    shown: true
    ...
    DragHandle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: units.gu(2)

        direction: SwipeArea::Leftwards
    }
  }

 */
SwipeArea {
    id: dragArea

    property bool stretch: false

    property alias autoCompleteDragThreshold: dragEvaluator.dragThreshold

    // How far you can drag
    property real maxTotalDragDistance: {
        if (stretch) {
            0; // not enough context information to set a sensible default
        } else {
            Direction.isHorizontal(direction) ? parent.width : parent.height;
        }
    }

    property real hintDisplacement: 0

    immediateRecognition: hintDisplacement > 0

    property var overrideStartValue: undefined
    SmoothedAnimation {
        id: hintingAnimation
        target: hintingAnimation
        property: "targetValue"
        duration: 150
        velocity: -1

        to: d.incrementTargetProp ? d.startValue + hintDisplacement
                                  : d.startValue - hintDisplacement
        property real targetValue
        onTargetValueChanged: {
            if (!running) {
                return;
            }

            if (d.incrementTargetProp) {
                if (parent[d.targetProp] < targetValue) {
                    parent[d.targetProp] = targetValue;
                }
            } else {
                if (parent[d.targetProp] > targetValue) {
                    parent[d.targetProp] = targetValue;
                }
            }
        }
    }

    // Private stuff
    QtObject {
        id: d

        // Whether movement along the designated direction will increment the value of the target property
        readonly property bool incrementTargetProp: (Direction.isPositive(direction) && !dragArea.stretch)
                                                 || (dragArea.stretch && !d.dragParent.shown)

        property real startValue
        property real minValue: {
            if (direction == Direction.Horizontal) {
                return startValue - maxTotalDragDistance;
            } else if (incrementTargetProp) {
                return startValue;
            } else {
                return startValue - maxTotalDragDistance;
            }
        }

        property real maxValue: incrementTargetProp ? startValue + maxTotalDragDistance
                                                    : startValue;

        property var dragParent: dragArea.parent

        // The property of DragHandle's parent that will be modified
        property string targetProp: {
            if (stretch) {
                Direction.isHorizontal(direction) ? "width" : "height";
            } else {
                Direction.isHorizontal(direction) ? "x" : "y";
            }
        }

        function limitMovement(distance) {
            var targetValue = MathUtils.clamp(d.startValue + distance, minValue, maxValue);
            var diff = targetValue - d.startValue;

            if (hintDisplacement == 0) {
                return diff;
            }

            // we should not go behind hintingAnimation's current value
            if (d.incrementTargetProp) {
                if (d.startValue + diff < hintingAnimation.targetValue) {
                    diff = hintingAnimation.targetValue - d.startValue;
                }
            } else {
                if (d.startValue + diff > hintingAnimation.targetValue) {
                    diff = hintingAnimation.targetValue - d.startValue;
                }
            }

            return diff;
        }

        function onFinishedRecognizedGesture() {
            if (dragEvaluator.shouldAutoComplete()) {
                completeDrag();
            } else {
                rollbackDrag();
            }
        }

        function completeDrag() {
            if (dragParent.shown) {
                dragParent.hide();
            } else {
                dragParent.show();
            }
        }

        function rollbackDrag() {
            if (dragParent.shown) {
                dragParent.show();
            } else {
                dragParent.hide();
            }
        }
    }

    property alias edgeDragEvaluator: dragEvaluator

    EdgeDragEvaluator {
        objectName: "edgeDragEvaluator"
        id: dragEvaluator
        // Effectively convert distance into the drag position projected onto the gesture direction axis
        trackedPosition: Direction.isPositive(dragArea.direction) ? distance : -distance
        maxDragDistance: maxTotalDragDistance
        direction: dragArea.direction
    }

    onDistanceChanged: {
        if (dragging) {
            if (!Direction.isPositive(direction))
                distance = -distance;

            if (dragArea.stretch &&
                   ((!Direction.isPositive(direction) && !d.dragParent.shown)
                     ||
                    (Direction.isPositive(direction) && d.dragParent.shown))
               )
            {
                // This happens when you have a stretching showable being shown from the right or
                // top edge (and consequently being hidden when dragged towards the right/top edge)
                // In those situations, dimension expansion/retraction happens in the opposite
                // sign of the axis direction
                distance = -distance;
            }

            var toAdd = d.limitMovement(distance);
            parent[d.targetProp] = d.startValue + toAdd;
        }
    }

    onDraggingChanged: {
        if (dragging) {
            dragEvaluator.reset();
            if (overrideStartValue !== undefined) {
                d.startValue = overrideStartValue;
            } else {
                d.startValue = parent[d.targetProp];
            }

            if (hintDisplacement > 0) {
                hintingAnimation.targetValue = d.startValue;
                hintingAnimation.start();
            }
        } else {
            hintingAnimation.stop();
            d.onFinishedRecognizedGesture();
        }
    }
}
