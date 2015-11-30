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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1
import ".."
import "../../../qml/Components/PanelState"
import "../../../qml/Stages"
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Application 0.1

Item {
    id: root
    height: units.gu(60)
    width: units.gu(85)

    Binding {
        target: PanelState
        property: "panelHeight"
        value: units.gu(2)
    }

    Component {
        id: fakeWindowComponent

        Item {
            id: fakeWindow
            property alias resizeAreaMinWidth: windowResizeArea.minWidth
            property alias resizeAreaMinHeight: windowResizeArea.minHeight
            x: units.gu(20)
            y: units.gu(20)
            width: requestedWidth
            height: requestedHeight
            property real requestedWidth
            property real requestedHeight
            property real minimumWidth: 0
            property real minimumHeight: 0
            property real maximumWidth: 0
            property real maximumHeight: 0
            property real widthIncrement: 0
            property real heightIncrement: 0
            state: "normal"

            function maximize() {
                state = "maximized"
            }

            WindowResizeArea {
                id: windowResizeArea
                target: fakeWindow
                borderThickness: units.gu(2)
                minWidth: units.gu(15)
                minHeight: units.gu(10)
                defaultWidth: units.gu(20)
                defaultHeight: units.gu(20)
                windowId: "test-window-id"
                screenWidth: root.width
                screenHeight: root.height
            }

            Rectangle {
                anchors.fill: windowResizeArea
                color: "red"
            }

            Rectangle {
                anchors.fill: fakeWindow
                color: "blue"
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                }
                Text {
                    text: parent.width + "x" + parent.height
                    color: "white"
                }
            }
        }
    }

    Loader {
        id: windowLoader
        sourceComponent: fakeWindowComponent
        active: windowLoaderCheckbox.checked
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: units.gu(25)
        color: "lightgrey"
        Column {
            width: parent.width
            spacing: units.gu(1)
            MouseTouchEmulationCheckbox {
                checked: false
                color: "black"
            }
            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: windowLoaderCheckbox
                    checked: true
                    activeFocusOnPress: false
                }
                Label {
                    color: "black"
                    text: "Window loader active"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Label {
                color: "black"; font.bold: true
                text: "Size Hints:"
            }
            SizeHintField { id: minWidthText; text: "min width" }
            SizeHintField { id: maxWidthText; text: "max width" }
            SizeHintField { id: minHeightText; text: "min height" }
            SizeHintField { id: maxHeightText; text: "max height" }
            SizeHintField { id: widthIncrText; text: "width incr" }
            SizeHintField { id: heightIncrText; text: "height incr" }
            Button {
                color: "black"
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Apply"
                onClicked: {
                    var value = parseInt(minWidthText.value);
                    if (isNaN(value)) {
                        windowLoader.item.minimumWidth = 0;
                    } else {
                        windowLoader.item.resizeAreaMinWidth = 1; // get it out of the way
                        windowLoader.item.minimumWidth = value;
                    }

                    value = parseInt(maxWidthText.value);
                    if (isNaN(value)) {
                        windowLoader.item.maximumWidth = 0;
                    } else {
                        windowLoader.item.maximumWidth = value;
                    }

                    value = parseInt(minHeightText.value);
                    if (isNaN(value)) {
                        windowLoader.item.minimumHeight = 0;
                    } else {
                        windowLoader.item.resizeAreaMinHeight = 1; // get it out of the way
                        windowLoader.item.minimumHeight = value;
                    }

                    value = parseInt(maxHeightText.value);
                    if (isNaN(value)) {
                        windowLoader.item.maximumHeight = 0;
                    } else {
                        windowLoader.item.maximumHeight = value;
                    }

                    value = parseInt(widthIncrText.value);
                    if (isNaN(value)) {
                        windowLoader.item.widthIncrement = 0;
                    } else {
                        windowLoader.item.widthIncrement = value;
                    }

                    value = parseInt(heightIncrText.value);
                    if (isNaN(value)) {
                        windowLoader.item.heightIncrement = 0;
                    } else {
                        windowLoader.item.heightIncrement = value;
                    }
                }
            }
        }
    }

    SignalSpy {
        id: windowRequestedWidthSpy
        target: windowLoader.item
        signalName: "onRequestedWidthChanged"
    }

    SignalSpy {
        id: windowRequestedHeightSpy
        target: windowLoader.item
        signalName: "onRequestedHeightChanged"
    }

    UnityTestCase {
        name: "WindowResizeArea"
        when: windowShown

        property var fakeWindow: windowLoader.item

        function init() {
            fakeWindow.x = units.gu(20)
            fakeWindow.y = units.gu(20)
            fakeWindow.requestedWidth = units.gu(20)
            fakeWindow.requestedHeight = units.gu(20)
            fakeWindow.resizeAreaMinWidth = units.gu(15);
            fakeWindow.resizeAreaMinHeight = units.gu(10);
            fakeWindow.minimumWidth = 0;
            fakeWindow.minimumHeight = 0;
            fakeWindow.maximumWidth = 0;
            fakeWindow.maximumHeight = 0;
            fakeWindow.widthIncrement = 0;
            fakeWindow.heightIncrement = 0;

            // Our test window resizes instantly
            compare(fakeWindow.width, fakeWindow.requestedWidth);
            compare(fakeWindow.height, fakeWindow.requestedHeight);
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

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth + data.dx, fakeWindow.resizeAreaMinWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight + data.dy, fakeWindow.resizeAreaMinHeight));

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

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth - data.dx, fakeWindow.resizeAreaMinWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight - data.dy, fakeWindow.resizeAreaMinHeight));

            var maxMoveX = initialWindowWidth - fakeWindow.resizeAreaMinWidth;
            var maxMoveY = initialWindowHeight - fakeWindow.resizeAreaMinHeight;
            compare(fakeWindow.x, Math.min(initialWindowX + data.dx, initialWindowX + maxMoveX));
            compare(fakeWindow.y, Math.min(initialWindowY + data.dy, initialWindowY + maxMoveY));
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

            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth + resizeDelta, fakeWindow.resizeAreaMinWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight + resizeDelta, fakeWindow.resizeAreaMinHeight));

            // This will destroy the window and recreate it
            windowLoader.active = false;
            waitForRendering(root);
            windowLoader.active = true;

            // Make sure its size is again the same as before
            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth + resizeDelta, fakeWindow.resizeAreaMinWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight + resizeDelta, fakeWindow.resizeAreaMinHeight));
        }

        // This tests if dragging smaller than minSize and then larger again, will keep the edge sticking
        // to the mouse, instead of immediately making the window grow again when switching direction
        function test_resizeSmallerAndLarger_data() {
            return [
                { tag: "topLeft", startX: -1, startY: -1, dx: units.gu(15), dy: units.gu(15) },
                { tag: "bottomRight", startX: units.gu(20) + 1, startY: units.gu(20) + 1, dx: -units.gu(15), dy: -units.gu(15) }
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
            tryCompare(fakeWindow, "width", Math.max(initialWindowWidth - Math.abs(data.dx), fakeWindow.resizeAreaMinWidth));
            tryCompare(fakeWindow, "height", Math.max(initialWindowHeight - Math.abs(data.dy), fakeWindow.resizeAreaMinHeight));
            mouseFlick(root, startDragX + data.dx, startDragY + data.dy, startDragX, startDragY, false, true, units.gu(.05), 10);
            tryCompare(fakeWindow, "width", initialWindowWidth);
            tryCompare(fakeWindow, "height", initialWindowHeight);
        }

        function test_saveRestoreMaximized() {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;

            var moveDelta = units.gu(5);

            fakeWindow.x = initialWindowX + moveDelta
            fakeWindow.y = initialWindowY + moveDelta

            // Now change the state to maximized. The window should not keep updating the stored values
            fakeWindow.state = "maximized"
            fakeWindow.x = 31415 // 0 is too risky to pass the test even when broken
            fakeWindow.y = 31415

            // This will destroy the window and recreate it
            windowLoader.active = false;
            waitForRendering(root);
            windowLoader.active = true;

            // Make sure it's again where we left it in normal state before destroying
            tryCompare(fakeWindow, "x", initialWindowX + moveDelta)
            tryCompare(fakeWindow, "y", initialWindowX + moveDelta)

            // Make sure maximize() has been called after restoring
            tryCompare(fakeWindow, "state", "maximized")

            // clean up
            fakeWindow.state = "normal"
        }

        function test_restoreMovesIntoBounds_data() {
            return [
                        {tag: "left off", x: -units.gu(5), y: units.gu(5), w: units.gu(10), h: units.gu(10)},
                        {tag: "top off", x: units.gu(5), y: -units.gu(5), w: units.gu(10), h: units.gu(10)},
                        {tag: "right off", x: root.width - units.gu(5), y: units.gu(5), w: units.gu(10), h: units.gu(10)},
                        {tag: "bottom off", x: units.gu(5), y: root.height - units.gu(5), w: units.gu(10), h: units.gu(10)},
                        {tag: "width too large", x: units.gu(5), y: units.gu(5), w: root.width * 2, h: units.gu(10)},
                        {tag: "height too large", x: units.gu(5), y: units.gu(5), w: units.gu(10), h: root.height * 2}
                ]
        }

        function test_restoreMovesIntoBounds(data) {
            fakeWindow.x = data.x;
            fakeWindow.y = data.y;
            fakeWindow.width = data.w;
            fakeWindow.height = data.h;
            waitForRendering(root);

            // This will destroy the window and recreate it
            windowLoader.active = false;
            waitForRendering(root);
            windowLoader.active = true;
            waitForRendering(root)

            // Make sure it's again where we left it in normal state before destroying
            compare(fakeWindow.x >= 0, true)
            compare(fakeWindow.y >= PanelState.panelHeight, true)
            compare(fakeWindow.x + fakeWindow.width <= root.width, true)
            compare(fakeWindow.y + fakeWindow.height <= root.height, true)

            waitForRendering(root)
        }

        /*
            Tests that even though you dragged the window bottom right corner continously (ie,
            through multiple intermediate steps), its (requested) width and height changed only
            once. And, furthermore, its dimensions increased by a multiple of its size (width
            and height) increment value.
         */
        function test_sizeIncrement() {
            var initialWindowX = fakeWindow.x;
            var initialWindowY = fakeWindow.y;
            var initialWindowWidth = fakeWindow.width
            var initialWindowHeight = fakeWindow.height

            fakeWindow.widthIncrement = 70;
            fakeWindow.heightIncrement = 70;

            var startDragX = initialWindowX + initialWindowWidth + 1
            var startDragY = initialWindowY + initialWindowHeight + 1
            var deltaX = 100;
            var deltaY = 100;

            windowRequestedWidthSpy.clear();
            verify(windowRequestedWidthSpy.valid);

            windowRequestedHeightSpy.clear();
            verify(windowRequestedHeightSpy.valid);

            mouseFlick(root, startDragX, startDragY, startDragX + deltaX, startDragY + deltaY, true, true, units.gu(.5), 10);

            compare(windowRequestedWidthSpy.count, 1);
            compare(fakeWindow.width, initialWindowWidth + fakeWindow.widthIncrement);
            compare(windowRequestedHeightSpy.count, 1);
            compare(fakeWindow.height, initialWindowHeight + fakeWindow.heightIncrement);
        }

        /*
            Tests that when dragging a window border you cannot make it bigger than its maximum size
         */
        function test_maximumSize() {
            fakeWindow.x = units.gu(1);
            fakeWindow.y = units.gu(1);
            fakeWindow.resizeAreaMinWidth = 1; // so it does not interfere with anything
            fakeWindow.resizeAreaMinHeight = 1; // so it does not interfere with anything
            fakeWindow.requestedWidth = units.gu(10);
            fakeWindow.requestedHeight = units.gu(10);

            fakeWindow.maximumWidth = units.gu(20);
            fakeWindow.maximumHeight = units.gu(20);

            // Our test window resizes instantly
            compare(fakeWindow.width, fakeWindow.requestedWidth);
            compare(fakeWindow.height, fakeWindow.requestedHeight);

            var startDragX = fakeWindow.width + 1
            var startDragY = fakeWindow.height + 1
            var endDragX = (fakeWindow.maximumWidth * 2) + 1;
            var endDragY = (fakeWindow.maximumHeight * 2) + 1;

            mouseFlick(fakeWindow, startDragX, startDragY, endDragX, endDragY,
                    true/*pressMouse*/, true/*releaseMouse*/, units.gu(.5)/*speed*/, 20/*iterations*/);

            compare(fakeWindow.requestedWidth, fakeWindow.maximumWidth);
            compare(fakeWindow.requestedHeight, fakeWindow.maximumHeight);
        }

        /*
            Tests that when dragging a window border you cannot make it smaller than its minimum size
         */
        function test_minimumSize() {
            fakeWindow.x = units.gu(1);
            fakeWindow.y = units.gu(1);
            fakeWindow.resizeAreaMinWidth = 1; // so it does not interfere with anything
            fakeWindow.resizeAreaMinHeight = 1; // so it does not interfere with anything
            fakeWindow.requestedWidth = units.gu(20);
            fakeWindow.requestedHeight = units.gu(20);

            fakeWindow.minimumWidth = units.gu(10);
            fakeWindow.minimumHeight = units.gu(10);

            // Our test window resizes instantly
            compare(fakeWindow.width, fakeWindow.requestedWidth);
            compare(fakeWindow.height, fakeWindow.requestedHeight);

            var startDragX = fakeWindow.width + 1
            var startDragY = fakeWindow.height + 1
            var endDragX = (fakeWindow.minimumWidth * 0.5) + 1;
            var endDragY = (fakeWindow.minimumHeight * 0.5) + 1;

            mouseFlick(fakeWindow, startDragX, startDragY, endDragX, endDragY,
                    true/*pressMouse*/, true/*releaseMouse*/, units.gu(.5)/*speed*/, 20/*iterations*/);

            compare(fakeWindow.requestedWidth, fakeWindow.minimumWidth);
            compare(fakeWindow.requestedHeight, fakeWindow.minimumHeight);
        }
    }
}
