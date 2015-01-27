/*
 * Copyright 2014 Canonical Ltd.
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

    Rectangle {
        id: fakeWindow
        height: units.gu(20)
        width: units.gu(20)
        color: "khaki"
        WindowMoveResizeArea {
            id: moveResizeArea
            target: fakeWindow
            resizeHandleWidth: units.gu(0.5)
            minWidth: units.gu(15)
            minHeight: units.gu(10)
        }
    }

    UT.UnityTestCase {
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

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth + data.dx, moveResizeArea.minWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight + data.dy, moveResizeArea.minHeight));

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

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth - data.dx, moveResizeArea.minWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight - data.dy, moveResizeArea.minHeight));

            var maxMoveX = initialWindowWidth - moveResizeArea.minWidth;
            var maxMoveY = initialWindowHeight - moveResizeArea.minHeight;
            compare(fakeWindow.x, Math.min(initialWindowX + data.dx, initialWindowX + maxMoveX));
            compare(fakeWindow.y, Math.min(initialWindowY + data.dy, initialWindowY + maxMoveY));
        }
    }
}
