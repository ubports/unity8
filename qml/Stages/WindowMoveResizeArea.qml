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
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

import QtQuick 2.3
import Ubuntu.Components 1.1
import "../Components/WindowStateStorage"

MouseArea {
    id: root
    anchors.fill: target
    anchors.margins: -resizeHandleWidth

    // The target item managed by this. Must be a parent or a sibling
    // The area will anchor to it and manage move and resize events
    property Item target: null
    property string windowId: ""
    property int resizeHandleWidth: 0
    property int minWidth: 0
    property int minHeight: 0

    QtObject {
        id: priv
        readonly property int windowWidth: root.width - root.resizeHandleWidth * 2
        readonly property int windowHeight: root.height - resizeHandleWidth * 2

        property var startPoint
        property int startWidth
        property int startHeight

        property bool resizeTop: false
        property bool resizeBottom: false
        property bool resizeLeft: false
        property bool resizeRight: false

    }

    Component.onCompleted: {
        var windowState = WindowStateStorage.getState(root.windowId)
        if (windowState !== undefined) {
            target.x = windowState.x
            target.y = windowState.y
            target.width = windowState.width
            target.height = windowState.height
        }
    }

    onPressed: {
        priv.startPoint = mapToItem(null, Qt.point(mouse.x, mouse.y)).x;
        priv.startWidth = root.width;
        priv.startHeight = root.height;
        priv.resizeTop = mouseY < root.resizeHandleWidth;
        priv.resizeBottom = mouseY > (root.height - root.resizeHandleWidth);
        priv.resizeLeft = mouseX < root.resizeHandleWidth;
        priv.resizeRight = mouseX > (root.width - root.resizeHandleWidth);
    }

    onPositionChanged: {
        var currentPoint = mapToItem(null, Qt.point(mouse.x, mouse.y)).x;
        var mouseDiff = Qt.point(currentPoint.x - priv.startPoint.x, currentPoint.y - priv.startPoint.y);
        var moveDiff = Qt.point(0, 0);
        var sizeDiff = Qt.point(0, 0);
        var maxSizeDiff = Qt.point(root.minWidth - root.target.width, root.minHeight - root.target.height)

        if (priv.resizeTop || priv.resizeBottom || priv.resizeLeft || priv.resizeRight) {
            if (priv.resizeTop) {
                sizeDiff.y = Math.max(maxSizeDiff.y, -currentPoint.y + priv.startPoint.y)
                moveDiff.y = -sizeDiff.y
            }
            if (priv.resizeBottom) {
                sizeDiff.y = Math.max(maxSizeDiff.y, currentPoint.y - priv.startPoint.y)
                priv.startPoint.y += sizeDiff.y
            }
            if (priv.resizeLeft) {
                sizeDiff.x = Math.max(maxSizeDiff.x, -currentPoint.x + priv.startPoint.x)
                moveDiff.x = -sizeDiff.x
            }
            if (priv.resizeRight) {
                sizeDiff.x = Math.max(maxSizeDiff.x, currentPoint.x - priv.startPoint.x)
                priv.startPoint.x += sizeDiff.x
            }

            target.x += moveDiff.x;
            target.y += moveDiff.y;
            target.width += sizeDiff.x;
            target.height += sizeDiff.y;
        } else {
            target.x += mouseDiff.x;
            target.y += mouseDiff.y;
        }

    }

    onReleased: {
        WindowStateStorage.saveState(root.windowId,target.x, target.y, target.width, target.height)
    }
}
