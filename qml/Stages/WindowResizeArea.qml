/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.1
import Utils 0.1
import Unity.Application 0.1 // for Mir.cursorName

MouseArea {
    id: root
    anchors.fill: target
    anchors.margins: -borderThickness

    hoverEnabled: true

    property var windowStateStorage: WindowStateStorage

    // The target item managed by this. Must be a parent or a sibling
    // The area will anchor to it and manage move and resize events
    property Item target: null
    property string windowId: ""
    property int borderThickness: 0
    property int minWidth: 0
    property int minHeight: 0
    property int defaultWidth: units.gu(60)
    property int defaultHeight: units.gu(50)

    Component.onCompleted: {
        var windowState = windowStateStorage.getGeometry(root.windowId,
                Qt.rect(target.x, target.y, defaultWidth, defaultHeight) /* default geometry */);

        target.x = windowState.x;
        target.y = windowState.y;
        target.requestedWidth = Math.max(windowState.width, minWidth);
        target.requestedHeight = Math.max(windowState.height, minHeight);
    }

    Component.onDestruction: {
        windowStateStorage.saveGeometry(root.windowId, Qt.rect(target.x, target.y, target.width, target.height))
    }

    QtObject {
        id: d
        property bool leftBorder: false
        property bool rightBorder: false
        property bool topBorder: false
        property bool bottomBorder: false

        property bool dragging: false
        property real startMousePosX
        property real startMousePosY
        property real startX
        property real startY
        property real startWidth
        property real startHeight
        property real currentWidth
        property real currentHeight

        property string cursorName: {
            if (root.containsMouse || root.pressed) {
                if (leftBorder && !topBorder && !bottomBorder) {
                    return "left_side";
                } else if (rightBorder && !topBorder && !bottomBorder) {
                    return "right_side";
                } else if (topBorder && !leftBorder && !rightBorder) {
                    return "top_side";
                } else if (bottomBorder && !leftBorder && !rightBorder) {
                    return "bottom_side";
                } else if (leftBorder && topBorder) {
                    return "top_left_corner";
                } else if (leftBorder && bottomBorder) {
                    return "bottom_left_corner";
                } else if (rightBorder && topBorder) {
                    return "top_right_corner";
                } else if (rightBorder && bottomBorder) {
                    return "bottom_right_corner";
                } else {
                    return "";
                }
            } else {
                return "";
            }
        }
        onCursorNameChanged: {
            Mir.cursorName = cursorName;
        }

        function updateBorders() {
            leftBorder = mouseX <= borderThickness;
            rightBorder = mouseX >= width - borderThickness;
            topBorder = mouseY <= borderThickness;
            bottomBorder = mouseY >= height - borderThickness;
        }
    }

    onPressedChanged: {
        var pos = mapToItem(target.parent, mouseX, mouseY);

        if (pressed) {
            d.updateBorders();
            var pos = mapToItem(root.target.parent, mouseX, mouseY);
            d.startMousePosX = pos.x;
            d.startMousePosY = pos.y;
            d.startX = target.x;
            d.startY = target.y;
            d.startWidth = target.width;
            d.startHeight = target.height;
            d.currentWidth = target.width;
            d.currentHeight = target.height;
            d.dragging = true;
        } else {
            d.dragging = false;
            if (containsMouse) {
                d.updateBorders();
            }
        }
    }

    onEntered: {
        if (!pressed) {
            d.updateBorders();
        }
    }

    onPositionChanged: {
        if (!pressed) {
            d.updateBorders();
        }

        if (!d.dragging) {
            return;
        }

        var pos = mapToItem(target.parent, mouse.x, mouse.y);

        var deltaX = pos.x - d.startMousePosX;
        var deltaY = pos.y - d.startMousePosY;

        if (d.leftBorder) {
            var newTargetX = d.startX + deltaX;
            if (target.x + target.width > newTargetX + minWidth) {
                target.requestedWidth = target.x + target.width - newTargetX;
            } else {
                target.requestedWidth = minWidth;
            }

        } else if (d.rightBorder) {
            if (d.startWidth + deltaX >= minWidth) {
                target.requestedWidth = d.startWidth + deltaX;
            } else {
                target.requestedWidth = minWidth;
            }
        }

        if (d.topBorder) {
            var newTargetY = d.startY + deltaY;
            if (target.y + target.height > newTargetY + minHeight) {
                target.requestedHeight = target.y + target.height - newTargetY;
            } else {
                target.requestedHeight = minHeight;
            }

        } else if (d.bottomBorder) {
            if (d.startHeight + deltaY >= minHeight) {
                target.requestedHeight = d.startHeight + deltaY;
            } else {
                target.requestedHeight = minHeight;
            }
        }
    }

    Connections {
        target: root.target
        onWidthChanged: {
            if (root.pressed && d.leftBorder) {
                target.x += d.currentWidth - target.width;
            }
            d.currentWidth = target.width;
        }
        onHeightChanged: {
            if (root.pressed && d.topBorder) {
                target.y += d.currentHeight - target.height;
            }
            d.currentHeight = target.height;
        }
    }
}
