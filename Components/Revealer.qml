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
import "Math.js" as MathLocal

Item {
    id: revealer

    property Showable target
    property var hintingAnimation: hintingAnimation
    property string boundProperty: orientation == Qt.Vertical ? "y" : "x"
    property int orientation: Qt.Vertical
    property int direction: Qt.LeftToRight
    property real openedValue: orientation == Qt.Vertical ? y : x
    property real closedValue: orientation == Qt.Vertical ? y + (direction == Qt.LeftToRight ? -height : height) : x + (direction == Qt.LeftToRight ? -width : width)
    property real hintDisplacement: 0
    property real handleSize: units.gu(2)
    property real dragVelocity: draggingArea.dragVelocity != 0 ? Math.abs(draggingArea.dragVelocity) : -1
    property real dragVelocityThreshold: units.gu(5)
    property bool dragging: false
    property bool pressed: draggingArea.pressed
    property int lateralPosition: draggingArea.lateralPosition
    property real dragPosition
    property bool openOnPress: true

    signal openPressed(int mouseX, int mouseY)
    signal openReleased(int mouseX, int mouseY)
    signal closePressed
    signal openClicked
    signal closeClicked

    dragPosition: {
        var value
        if (orientation == Qt.Vertical) {
            value = draggingArea.dragValue + draggingArea.y
            if (direction == Qt.RightToLeft) {
                value += draggingArea.height - height
            }
        } else {
            value = draggingArea.dragValue + draggingArea.x
            if (direction == Qt.RightToLeft) {
                value += draggingArea.width - width
            }
        }
        if (__opened) {
            if (direction == Qt.LeftToRight) {
                value += handleSize
            } else {
                value -= handleSize
            }
        } else if (dragging) {
            if (direction == Qt.LeftToRight) {
                value += hintDisplacement
            } else {
                value -= hintDisplacement
            }
        }

        return value
    }
    property var draggingArea: leftDraggingArea.enabled ? leftDraggingArea : rightDraggingArea

    property real __hintValue: closedValue + (direction == Qt.LeftToRight ? hintDisplacement : -hintDisplacement)

    function dragToValue(dragPosition) {
        return dragPosition + closedValue
    }

    property bool __opened: target.shown
    enabled: target.available

    // Can be replaced with a fake implementation during tests
    // property var __getCurrentTimeMs: function () { return new Date().getTime() }
    property var __dateTime: new function() {
        this.getCurrentTimeMs = function() {return new Date().getTime()}
    }

    Component.onCompleted: target[boundProperty] = __opened ? openedValue : closedValue
    onOpenedValueChanged: if (__opened && !dragging) target[boundProperty] = openedValue
    onClosedValueChanged: if (!__opened && !dragging) target[boundProperty] = closedValue

    function __computeValue(dragPosition) {
        return MathLocal.clamp(dragToValue(dragPosition), __hintValue, openedValue)
    }

    function __open() {
        hintingAnimation.stop()
        target.show()
    }

    function __close() {
        hintingAnimation.stop()
        target.hide()
    }

    function __hint() {
        target.showAnimation.stop()
        target.hideAnimation.stop()
        hintingAnimation.restart()
    }

    function __settle() {
        hintingAnimation.stop()
        if (__opened) target.show()
        else target.hide()
    }

    function __startDragging() {
        hintingAnimation.stop()
        dragging = true
    }

    function __endDragging(dragVelocity) {
        dragging = false
        if (revealer.direction == Qt.RightToLeft) {
            dragVelocity = -dragVelocity
        }
        if (Math.abs(dragVelocity) >= dragVelocityThreshold) {
            if (dragVelocity > 0) __open()
            else __close()
        } else {
            __settle()
        }
    }

    Binding {
        id: dragBinding

        target: revealer.target
        property: revealer.boundProperty
        value: __computeValue(dragPosition)
        when: dragging
    }

    SmoothedAnimation {
        id: hintingAnimation

        target: revealer.target
        property: revealer.boundProperty
        duration: 150
        to: revealer.__hintValue
    }

    DraggingArea {
        id: leftDraggingArea

        property bool isOpeningArea: revealer.direction == Qt.LeftToRight

        height: orientation == Qt.Vertical ? handleSize : parent.height
        width: orientation == Qt.Horizontal ? handleSize : parent.width
        orientation: revealer.orientation
        enabled: isOpeningArea ? !revealer.__opened : revealer.__opened

        __dateTime: revealer.__dateTime

        onPressed: {
            if (isOpeningArea) {
                if (revealer.openOnPress) {
                    revealer.openPressed(mouseX, mouseY)
                    __hint()
                }
            } else {
                revealer.closePressed()
            }
        }
        onReleased: {
            if (isOpeningArea && revealer.openOnPress) {
                revealer.openReleased(mouseX, mouseY)
                __settle()
            }
        }
        onDragStart: __startDragging()
        onDragEnd: __endDragging(dragVelocity)
        onClicked: {
            if (clickValidated) {
                if (isOpeningArea) {
                    if (revealer.openOnPress) revealer.openClicked()
                } else {
                    revealer.closeClicked()
                }
            }
        }
    }

    DraggingArea {
        id: rightDraggingArea

        property bool isOpeningArea: revealer.direction == Qt.RightToLeft

        x: orientation == Qt.Vertical ? 0 : parent.width - width
        y: orientation == Qt.Vertical ? parent.height - height : 0
        height: orientation == Qt.Vertical ? handleSize : parent.height
        width: orientation == Qt.Horizontal ? handleSize : parent.width
        orientation: revealer.orientation
        enabled: isOpeningArea ? !revealer.__opened : revealer.__opened

        __dateTime: revealer.__dateTime

        onPressed: {
            if (isOpeningArea) {
                if (revealer.openOnPress) {
                    revealer.openPressed(mouseX, mouseY)
                    __hint()
                }
            } else {
                revealer.closePressed()
            }
        }
        onReleased: {
            if (isOpeningArea && revealer.openOnPress) {
                revealer.openReleased(mouseX, mouseY)
                __settle()
            }
        }
        onDragStart: __startDragging()
        onDragEnd: __endDragging(dragVelocity)
        onClicked: {
            if (clickValidated) {
                if (isOpeningArea) {
                    if (revealer.openOnPress) revealer.openClicked()
                } else {
                    revealer.closeClicked()
                }
            }
        }
    }
}
