/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Utils 0.1
import Unity.Application 0.1 // for Mir.cursorName
import "../Components/PanelState"

MouseArea {
    id: root
    anchors.fill: target
    anchors.margins: -borderThickness

    hoverEnabled: target && !target.maximized // don't grab the resize under the panel

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
    property int screenWidth: 0
    property int screenHeight: 0
    property int leftMargin: 0

    QtObject {
        id: priv
        objectName: "priv"

        property int normalX: 0
        property int normalY: 0
        property int normalWidth: 0
        property int normalHeight: 0

        function updateNormalGeometry() {
            if (root.target.state == "normal") {
                normalX = root.target.x
                normalY = root.target.y
                normalWidth = root.target.width
                normalHeight = root.target.height
            }
        }
    }

    Connections {
        target: root.target
        onXChanged: priv.updateNormalGeometry();
        onYChanged: priv.updateNormalGeometry();
        onWidthChanged: priv.updateNormalGeometry();
        onHeightChanged: priv.updateNormalGeometry();
    }

    function loadWindowState() {
        var windowGeometry = windowStateStorage.getGeometry(root.windowId,
                                                            Qt.rect(target.x, target.y, defaultWidth, defaultHeight));

        target.requestedWidth = Qt.binding(function() { return Math.min(Math.max(windowGeometry.width, d.minimumWidth), screenWidth - root.leftMargin); });
        target.requestedHeight = Qt.binding(function() { return Math.min(Math.max(windowGeometry.height, d.minimumHeight),
                                                                         root.screenHeight - (target.fullscreen ? 0 : PanelState.panelHeight)); });
        target.x = Qt.binding(function() { return Math.max(Math.min(windowGeometry.x, root.screenWidth - root.leftMargin - target.requestedWidth),
                                                           (target.fullscreen ? 0 : root.leftMargin)); });
        target.y = Qt.binding(function() { return Math.max(Math.min(windowGeometry.y, root.screenHeight - target.requestedHeight), PanelState.panelHeight); });

        var windowState = windowStateStorage.getState(root.windowId, WindowStateStorage.WindowStateNormal)
        switch (windowState) {
            case WindowStateStorage.WindowStateNormal:
                break;
            case WindowStateStorage.WindowStateMaximized:
                target.maximize(false);
                break;
            case WindowStateStorage.WindowStateMaximizedLeft:
                target.maximizeLeft(false);
                break;
            case WindowStateStorage.WindowStateMaximizedRight:
                target.maximizeRight(false);
                break;
            case WindowStateStorage.WindowStateMaximizedHorizontally:
                target.maximizeHorizontally(false);
                break;
            case WindowStateStorage.WindowStateMaximizedVertically:
                target.maximizeVertically(false);
                break;
            default:
                console.warn("Unsupported window state");
                break;
        }

        priv.updateNormalGeometry();
    }

    function saveWindowState() {
        windowStateStorage.saveState(root.windowId, target.windowState & ~WindowStateStorage.WindowStateMinimized); // clear the minimized bit when saving
        windowStateStorage.saveGeometry(root.windowId, Qt.rect(priv.normalX, priv.normalY, priv.normalWidth, priv.normalHeight));
    }

    QtObject {
        id: d

        readonly property int maxSafeInt: 2147483647
        readonly property int maxSizeIncrement: units.gu(40)

        readonly property int minimumWidth: root.target ? Math.max(root.minWidth, root.target.minimumWidth) : root.minWidth
        onMinimumWidthChanged: {
            if (target.requestedWidth < minimumWidth) {
                target.requestedWidth = minimumWidth;
            }
        }
        readonly property int minimumHeight: root.target ? Math.max(root.minHeight, root.target.minimumHeight) : root.minHeight
        onMinimumHeightChanged: {
            if (target.requestedHeight < minimumHeight) {
                target.requestedHeight = minimumHeight;
            }
        }
        readonly property int maximumWidth: root.target && root.target.maximumWidth >= minimumWidth && root.target.maximumWidth > 0
            ? root.target.maximumWidth : maxSafeInt
        onMaximumWidthChanged: {
            if (target.requestedWidth > maximumWidth) {
                target.requestedWidth = maximumWidth;
            }
        }
        readonly property int maximumHeight: root.target && root.target.maximumHeight >= minimumHeight && root.target.maximumHeight > 0
            ? root.target.maximumHeight : maxSafeInt
        onMaximumHeightChanged: {
            if (target.requestedHeight > maximumHeight) {
                target.requestedHeight = maximumHeight;
            }
        }
        readonly property int widthIncrement: {
            if (!root.target) {
                return 1;
            }
            if (root.target.widthIncrement > 0) {
                if (root.target.widthIncrement < maxSizeIncrement) {
                    return root.target.widthIncrement;
                } else {
                    return maxSizeIncrement;
                }
            } else {
                return 1;
            }
        }
        readonly property int heightIncrement: {
            if (!root.target) {
                return 1;
            }
            if (root.target.heightIncrement > 0) {
                if (root.target.heightIncrement < maxSizeIncrement) {
                    return root.target.heightIncrement;
                } else {
                    return maxSizeIncrement;
                }
            } else {
                return 1;
            }
        }

        property bool leftBorder: false
        property bool rightBorder: false
        property bool topBorder: false
        property bool bottomBorder: false

        // true  - A change in surface size will cause the left border of the window to move accordingly.
        //         The window's right border will stay in the same position.
        // false - a change in surface size will cause the right border of the window to move accordingly.
        //         The window's left border will stay in the same position.
        property bool moveLeftBorder: false

        // true  - A change in surface size will cause the top border of the window to move accordingly.
        //         The window's bottom border will stay in the same position.
        // false - a change in surface size will cause the bottom border of the window to move accordingly.
        //         The window's top border will stay in the same position.
        property bool moveTopBorder: false

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

    Timer {
        id: resetBordersToMoveTimer
        interval: 2000
        onTriggered: {
            d.moveLeftBorder = false;
            d.moveTopBorder = false;
        }
    }

    onPressedChanged: {
        var pos = mapToItem(target.parent, mouseX, mouseY);

        if (pressed) {
            d.updateBorders();
            resetBordersToMoveTimer.stop();
            d.moveLeftBorder = d.leftBorder;
            d.moveTopBorder = d.topBorder;

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
            resetBordersToMoveTimer.start();
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

        var deltaX = Math.floor((pos.x - d.startMousePosX) / d.widthIncrement) * d.widthIncrement;
        var deltaY = Math.floor((pos.y - d.startMousePosY) / d.heightIncrement) * d.heightIncrement;

        if (d.leftBorder) {
            var newTargetX = d.startX + deltaX;
            var rightBorderX = target.x + target.width;
            if (rightBorderX > newTargetX + d.minimumWidth) {
                if (rightBorderX  < newTargetX + d.maximumWidth) {
                    target.requestedWidth = rightBorderX - newTargetX;
                } else {
                    target.requestedWidth = d.maximumWidth;
                }
            } else {
                target.requestedWidth = d.minimumWidth;
            }

        } else if (d.rightBorder) {
            var newWidth = d.startWidth + deltaX;
            if (newWidth > d.minimumWidth) {
                if (newWidth < d.maximumWidth) {
                    target.requestedWidth = newWidth;
                } else {
                    target.requestedWidth = d.maximumWidth;
                }
            } else {
                target.requestedWidth = d.minimumWidth;
            }
        }

        if (d.topBorder) {
            var newTargetY = Math.max(d.startY + deltaY, PanelState.panelHeight); // disallow resizing up past Panel
            var bottomBorderY = target.y + target.height;
            if (bottomBorderY > newTargetY + d.minimumHeight) {
                if (bottomBorderY < newTargetY + d.maximumHeight) {
                    target.requestedHeight = bottomBorderY - newTargetY;
                } else {
                    target.requestedHeight = d.maximumHeight;
                }
            } else {
                target.requestedHeight = d.minimumHeight;
            }

        } else if (d.bottomBorder) {
            var newHeight = d.startHeight + deltaY;
            if (newHeight > d.minimumHeight) {
                if (newHeight < d.maximumHeight) {
                    target.requestedHeight = newHeight;
                } else {
                    target.requestedHeight = d.maximumHeight;
                }
            } else {
                target.requestedHeight = d.minimumHeight;
            }
        }
    }

    Connections {
        target: root.target
        onWidthChanged: {
            if (d.moveLeftBorder) {
                target.x += d.currentWidth - target.width;
            }
            d.currentWidth = target.width;
        }
        onHeightChanged: {
            if (d.moveTopBorder) {
                target.y += d.currentHeight - target.height;
            }
            d.currentHeight = target.height;
        }
    }
}
