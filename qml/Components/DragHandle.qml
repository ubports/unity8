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

import QtQuick 2.0
import Ubuntu.Components 0.1
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

        direction: DirectionalDragArea::Leftwards
    }
  }

 */
EdgeDragArea {
    id: dragArea
    objectName: "dragHandle"

    // Disable most of the gesture recognition parameters by default when hinting is used as
    // it conflicts with the hinting idea.
    // The only part we keep in this situation is that it must be a single-finger gesture.
    distanceThreshold: hintDisplacement > 0 ? 0 : defaultDistanceThreshold
    maxSilenceTime: hintDisplacement > 0 ? 60*60*1000 : defaultMaxSilenceTime
    maxDeviation: hintDisplacement > 0 ? 999999 : defaultMaxDeviation

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
    property var overrideStartValue: undefined
    SmoothedAnimation {
        id: hintingAnimation
        target: hintingAnimation
        property: "targetValue"
        duration: 150
        velocity: -1
        to: Direction.isPositive(direction) ? d.startValue + hintDisplacement
                                            : d.startValue - hintDisplacement
        property real targetValue
        onTargetValueChanged: {
            if (!running) {
                return;
            }

            if (Direction.isPositive(direction)) {
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
        property var previousStatus: DirectionalDragArea.WaitingForTouch
        property real startValue
        property real minValue: Direction.isPositive(direction) ? startValue
                                                                : startValue - maxTotalDragDistance
        property real maxValue: Direction.isPositive(direction) ? startValue + maxTotalDragDistance
                                                                : startValue

        property var dragParent: dragArea.parent

        // The property of DragHandle's parent that will be modified
        property string targetProp: {
            if (stretch) {
                Direction.isHorizontal(direction) ? "width" : "height";
            } else {
                Direction.isHorizontal(direction) ? "x" : "y";
            }
        }

        function limitMovement(inputStep) {
            var targetValue = MathUtils.clamp(dragParent[targetProp] + inputStep, minValue, maxValue);
            var step = targetValue - dragParent[targetProp];

            if (hintDisplacement == 0) {
                return step;
            }

            // we should not go behind hintingAnimation's current value
            if (Direction.isPositive(direction)) {
                if (dragParent[targetProp] + step < hintingAnimation.targetValue) {
                    step = hintingAnimation.targetValue - dragParent[targetProp];
                }
            } else {
                if (dragParent[targetProp] + step > hintingAnimation.targetValue) {
                    step = hintingAnimation.targetValue - dragParent[targetProp];
                }
            }

            return step;
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
        trackedPosition: Direction.isPositive(dragArea.direction) ? sceneDistance : -sceneDistance
        maxDragDistance: maxTotalDragDistance
        direction: dragArea.direction
    }

    onDistanceChanged: {
        if (status === DirectionalDragArea.Recognized) {
            // don't go the whole distance in order to smooth out the movement
            var step = distance * 0.3;

            step = d.limitMovement(step);

            parent[d.targetProp] += step;
        }
    }

    onStatusChanged: {
        if (status === DirectionalDragArea.WaitingForTouch) {
            hintingAnimation.stop();
            if (d.previousStatus === DirectionalDragArea.Recognized) {
                d.onFinishedRecognizedGesture();
            } else /* d.previousStatus === DirectionalDragArea.Undecided */ {
                // Gesture was rejected.
                d.rollbackDrag();
            }
        } else /* Undecided || Recognized */ {
            if (d.previousStatus === DirectionalDragArea.WaitingForTouch) {
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
            }
        }

        d.previousStatus = status;
    }
}
