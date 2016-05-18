/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
    A Flickable that can be put in front of the item to be flicked and
    still have the item-to-be-flicked receive input events that are not flicks.

    Ie, it's a Flickable that, input-wise, is transparent to non-flick gestures.

    With a regular Flickable you would have to make the item-to-be-flicked a child
    of Flicakble to achieve the same result. FloatingFlickable has no such requirement
    or limitation.
 */
Item {
    property alias contentWidth: flickable.contentWidth
    property alias contentHeight: flickable.contentHeight
    property alias contentX: flickable.contentX
    property alias contentY: flickable.contentY
    property alias direction: swipeArea.direction

    MouseEventGenerator {
        id: mouseEventGenerator
        targetItem: flickable
    }

    Flickable {
        id: flickable
        enabled: false
        anchors.fill: parent
        flickableDirection: Direction.isHorizontal(swipeArea.direction) ? Flickable.HorizontalFlick : Flickable.VerticalFlick
    }

    SwipeArea {
        id: swipeArea
        anchors.fill: parent
        direction: Direction.Horizontal

        onTouchPositionChanged: mouseEventGenerator.move(touchPosition);
        onDraggingChanged: dragging ? mouseEventGenerator.press(touchPosition)
                                    : mouseEventGenerator.release(touchPosition)
    }
}
