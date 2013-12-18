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
import "../../../qml/Components"

Item {
    id: revealingRectangle

    property int orientation: Qt.Vertical
    property int direction: Qt.LeftToRight
    property Revealer revealer: __revealer
    property Showable showable: __showable

    Revealer {
        id: __revealer

        target: __showable
        width: target.width
        height: target.height
        x: orientation == Qt.Vertical ? 0 : direction == Qt.LeftToRight ? 0 : parent.width - width
        y: orientation == Qt.Horizontal ? 0 : direction == Qt.LeftToRight ? 0 : parent.height - height
        handleSize: orientation == Qt.Vertical ? handle.height : handle.width
        hintDisplacement: handleSize
        orientation: revealingRectangle.orientation
        direction: revealingRectangle.direction
    }

    Showable {
        id: __showable

        width: orientation == Qt.Horizontal ? units.gu(24) : parent.width
        height: orientation == Qt.Vertical ? units.gu(24) : parent.height

        shown: false
        showAnimation: SmoothedAnimation {
            property: orientation == Qt.Horizontal ? "x" : "y"
            velocity: __revealer.dragVelocity
            duration: 200
            to: __revealer.openedValue
        }
        hideAnimation: SmoothedAnimation {
            property: orientation == Qt.Horizontal ? "x" : "y"
            velocity: __revealer.dragVelocity
            duration: 200
            to: __revealer.closedValue
        }

        Rectangle {
            anchors.fill: parent
            color: "red"
        }

        Rectangle {
            id: handle

            x: orientation == Qt.Vertical ? 0 : direction == Qt.LeftToRight ? parent.width - width : 0
            y: orientation == Qt.Horizontal ? 0 : direction == Qt.LeftToRight ? parent.height - height : 0
            width: orientation == Qt.Horizontal ? units.gu(2) : parent.width
            height: orientation == Qt.Vertical ? units.gu(2) : parent.height
            color: "black"
        }
    }
}
