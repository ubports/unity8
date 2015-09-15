/*
 * Copyright 2014-2015 Canonical Ltd.
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Stages"
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Unity.Application 0.1

Item {
    id: root
    height: units.gu(60)
    width: units.gu(60)

    property var fakeWindow: windowLoader.item

    Component {
        id: fakeWindowComponent

        Item {
            id: fakeWindow
            property alias minWidth: moveResizeArea.minWidth
            property alias minHeight: moveResizeArea.minHeight
            x: units.gu(20)
            y: units.gu(20)
            height: units.gu(20)
            width: units.gu(20)
            property int windowHeight: height
            property int windowWidth: width
            onWindowHeightChanged: height = windowHeight
            onWindowWidthChanged: width = windowWidth

            WindowMoveResizeArea {
                id: moveResizeArea
                target: fakeWindow
                resizeHandleWidth: units.gu(0.5)
                minWidth: units.gu(15)
                minHeight: units.gu(10)
                windowId: "test-window-id"
            }

            Rectangle {
                anchors.fill: moveResizeArea
                color: "red"
            }

            Rectangle {
                anchors.fill: fakeWindow
                color: "blue"
            }
        }
    }

    Loader {
        id: windowLoader
        sourceComponent: fakeWindowComponent
    }

    UT.UnityTestCase {
        name: "WindowMoveResizeArea"
        when: windowShown

        function init() {
            fakeWindow.x = units.gu(20)
            fakeWindow.y = units.gu(20)
            fakeWindow.width = units.gu(20)
            fakeWindow.height = units.gu(20)
        }

        function test_dragWindow_data() {
            return [
                { tag: "up", dx: 0, dy: units.gu(-10) },
                { tag: "down", dx: 0, dy: units.gu(10) },
                { tag: "left", dx: units.gu(-10), dy: 0 },
                { tag: "right", dx: units.gu(10), dy: 0 },
                { tag: "right/down", dx: units.gu(10), dy: units.gu(10) },
                { tag: "left/down", dx: units.gu(-10), dy: units.gu(10) }
            ]
        }

        function test_dragWindow(data) {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;
            var initialWindowWidth = fakeWindow.width
            var initialWindowHeight = fakeWindow.height

            var startDragX = initialWindowX + fakeWindow.width / 2;
            var startDragY = initialWindowY + fakeWindow.height / 2;
            mouseFlick(root, startDragX, startDragY, startDragX + data.dx, startDragY + data.dy, true, true, units.gu(.5), 10)

            tryCompare(fakeWindow, "x", initialWindowX + data.dx)
            tryCompare(fakeWindow, "y", initialWindowX + data.dy)

            compare(fakeWindow.height, initialWindowHeight);
            compare(fakeWindow.width, initialWindowWidth);
        }

        function test_resizeWindowRightBottom_data() {
            return [
                { tag: "width", dx: units.gu(10), dy: 0 },
                { tag: "height", dx: 0, dy: units.gu(10) },
                { tag: "both", dx: units.gu(10), dy: units.gu(10) },
                { tag: "smaller than minimum size", dx: -units.gu(15), dy: -units.gu(15) }
            ]
        }

        function test_resizeWindowRightBottom(data) {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;
            var initialWindowWidth = fakeWindow.width
            var initialWindowHeight = fakeWindow.height

            var startDragX = initialWindowX + initialWindowWidth + 1
            var startDragY = initialWindowY + initialWindowHeight + 1
            mouseFlick(root, startDragX, startDragY, startDragX + data.dx, startDragY + data.dy, true, true, units.gu(.5), 10);

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth + data.dx, fakeWindow.minWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight + data.dy, fakeWindow.minHeight));

            compare(fakeWindow.x, initialWindowX);
            compare(fakeWindow.y, initialWindowY);
        }

        function test_resizeWindowLeftTop_data() {
            return [
                { tag: "width", dx: -units.gu(10), dy: 0 },
                { tag: "height", dx: 0, dy: -units.gu(10) },
                { tag: "both", dx: -units.gu(10), dy: -units.gu(10) },
                { tag: "smaller than minimum size", dx: units.gu(15), dy: units.gu(15) }
            ]
        }

        function test_resizeWindowLeftTop(data) {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;
            var initialWindowWidth = fakeWindow.width
            var initialWindowHeight = fakeWindow.height

            var startDragX = initialWindowX - 1
            var startDragY = initialWindowY - 1
            mouseFlick(root, startDragX, startDragY, startDragX + data.dx, startDragY + data.dy, true, true, units.gu(.5), 10);

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth - data.dx, fakeWindow.minWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight - data.dy, fakeWindow.minHeight));

            var maxMoveX = initialWindowWidth - fakeWindow.minWidth;
            var maxMoveY = initialWindowHeight - fakeWindow.minHeight;
            compare(fakeWindow.x, Math.min(initialWindowX + data.dx, initialWindowX + maxMoveX));
            compare(fakeWindow.y, Math.min(initialWindowY + data.dy, initialWindowY + maxMoveY));
        }

        function test_saveRestorePosition() {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;
            var initialWindowWidth = fakeWindow.width;
            var initialWindowHeight = fakeWindow.height;

            var moveDelta = units.gu(5);
            var startDragX = initialWindowX + fakeWindow.width / 2;
            var startDragY = initialWindowY + fakeWindow.height / 2;
            mouseFlick(root, startDragX, startDragY, startDragX + moveDelta, startDragY + moveDelta, true, true, units.gu(.5), 10)

            tryCompare(fakeWindow, "x", initialWindowX + moveDelta)
            tryCompare(fakeWindow, "y", initialWindowX + moveDelta)

            // This will destroy the window and recreate it
            windowLoader.active = false;
            waitForRendering(root);
            windowLoader.active = true;

            // Make sure it's again where we left it before destroying
            tryCompare(fakeWindow, "x", initialWindowX + moveDelta)
            tryCompare(fakeWindow, "y", initialWindowX + moveDelta)
        }

        function test_saveRestoreSize() {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;
            var initialWindowWidth = fakeWindow.width
            var initialWindowHeight = fakeWindow.height

            var resizeDelta = units.gu(5)
            var startDragX = initialWindowX + initialWindowWidth + 1
            var startDragY = initialWindowY + initialWindowHeight + 1
            mouseFlick(root, startDragX, startDragY, startDragX + resizeDelta, startDragY + resizeDelta, true, true, units.gu(.5), 10);

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth + resizeDelta, fakeWindow.minWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight + resizeDelta, fakeWindow.minHeight));

            // This will destroy the window and recreate it
            windowLoader.active = false;
            waitForRendering(root);
            windowLoader.active = true;

            // Make sure its size is again the same as before
            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth + resizeDelta, fakeWindow.minWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight + resizeDelta, fakeWindow.minHeight));
        }

        // This tests if dragging smaller than minSize and then larger again, will keep the edge sticking
        // to the mouse, instead of immediately making the window grow again when switching direction
        function test_resizeSmallerAndLarger_data() {
            return [
                { tag: "topLeft", startX: -1, startY: -1, dx: units.gu(15), dy: units.gu(15) },
                { tag: "bottomRight", startX: fakeWindow.width + 1, startY: fakeWindow.height + 1, dx: -units.gu(15), dy: -units.gu(15) }
            ]
        }

        function test_resizeSmallerAndLarger(data) {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;
            var initialWindowWidth = fakeWindow.width
            var initialWindowHeight = fakeWindow.height

            var startDragX = initialWindowX + data.startX
            var startDragY = initialWindowY + data.startY
            mouseFlick(root, startDragX, startDragY, startDragX + data.dx, startDragY + data.dy, true, false, units.gu(.05), 10);
            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth - Math.abs(data.dx), fakeWindow.minWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight - Math.abs(data.dy), fakeWindow.minHeight));
            mouseFlick(root, startDragX + data.dx, startDragY + data.dy, startDragX, startDragY, false, true, units.gu(.05), 10);
            tryCompare(fakeWindow, "width", initialWindowWidth);
            tryCompare(fakeWindow, "height", initialWindowHeight);
        }
    }
}
