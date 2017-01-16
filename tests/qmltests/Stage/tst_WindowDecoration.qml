/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtTest 1.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Unity.Application 0.1
import Unity.Test 0.1
import Utils 0.1
import QMenuModel 0.1

import ".."
import "../../../qml/Stage"

Item {
    id: root
    width:  units.gu(70)
    height:  units.gu(50)

    Component.onCompleted: {
        QuickUtils.keyboardAttached = true;
        theme.name = "Ubuntu.Components.Themes.SuruDark"
    }

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    property QtObject application: QtObject {
        property string name: "webbrowser"
    }

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    UnityMenuModel {
        id: menuBackend
        modelData: appMenuData.generateTestData(5, 3, 3, "menu")
        onActivated: log.text = "Activated " + action + "\n" + log.text
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(1)
        }
        height: units.gu(20)
        border.width: 1
        border.color: "black"

        TextArea {
            id: log
            anchors.fill: parent
            readOnly: true
            color: "black"
        }
    }

    MouseArea {
        id: clickThroughTester
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
    }

    Loader {
        id: decorationLoader
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.margins: units.gu(1)
        height: units.gu(3)

        property bool itemDestroyed: false
        sourceComponent: WindowDecoration {
            anchors.fill: parent
            title: "TestTitle - Doing something"
            active: true
            menu: menuBackend

            onCloseClicked: { log.text = "Close\n" + log.text }
            onMinimizeClicked: { log.text = "Minimize\n" + log.text }
            onMaximizeClicked: { log.text = "Maximize\n" + log.text }

            Component.onDestruction: {
                decorationLoader.itemDestroyed = true;
            }
        }
    }

    SignalSpy {
        id: signalSpy
        target: decorationLoader.item
    }

    SignalSpy {
        id: mouseEaterSpy
        target: clickThroughTester
    }

    UnityTestCase {
        id: testCase
        name: "WindowDecoration"
        when: windowShown

        property Item decoration: decorationLoader.status === Loader.Ready ? decorationLoader.item : null

        function init() {
            tryCompareFunction(function() { return decoration !== null }, true);
            decoration.menu = menuBackend;

            waitForRendering(decoration);
        }

        function cleanup() {
            decorationLoader.itemDestroyed = false;
            decorationLoader.active = false;

            tryCompare(decorationLoader, "status", Loader.Null);
            tryCompare(decorationLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(decorationLoader, "itemDestroyed", true);

            decorationLoader.active = true;
            tryCompare(decorationLoader, "status", Loader.Ready);

            signalSpy.clear();
            mouseEaterSpy.clear();
        }

        function test_windowControlButtons_data() {
            return [ { tag: "close", controlName: "closeWindowButton", signal: "closeClicked"},
                    { tag: "minimize", controlName: "minimizeWindowButton", signal: "minimizeClicked"},
                    { tag: "maximize", controlName: "maximizeWindowButton", signal: "maximizeClicked"}];
        }

        function test_windowControlButtons(data) {
            signalSpy.signalName = data.signal;
            var controlButton = findChild(decoration, data.controlName);
            verify(controlButton !== null);

            mouseClick(controlButton, controlButton.width/2, controlButton.height/2);
            compare(signalSpy.count, 1);
        }

        function test_titleRemainsWhenHoveringOnTitleBarWithNoMenu() {
            decoration.menu = undefined;

            var menuLoader = findChild(decoration, "menuBarLoader");
            verify(menuLoader);
            mouseMove(menuLoader, menuLoader.width/2, menuLoader.height/2);
            wait(200);

            var titleLabel = findChild(decoration, "windowDecorationTitle");
            verify(menuLoader);

            compare(menuLoader.opacity, 0, "Menu should not show when present")
            compare(titleLabel.opacity, 1, "Title should always show when app menu not present")
        }

        function test_menuShowsWhenHoveringOnTitleBar() {
            var menuLoader = findChild(decoration, "menuBarLoader");
            verify(menuLoader);
            mouseMove(menuLoader, menuLoader.width/2, menuLoader.height/2)

            var titleLabel = findChild(decoration, "windowDecorationTitle");
            verify(menuLoader);

            tryCompare(menuLoader, "opacity", 1);
            tryCompare(titleLabel, "opacity", 0);

            mouseMove(menuLoader, menuLoader.width/2, menuLoader.height * 2);

            tryCompare(menuLoader, "opacity", 0);
            tryCompare(titleLabel, "opacity", 1);
        }

        function test_showMenuBarWithShortcutsOnLongAltPress() {
            var menuLoader = findChild(decoration, "menuBarLoader");
            verify(menuLoader);

            var titleLabel = findChild(decoration, "windowDecorationTitle");
            verify(menuLoader);

            var menuBar = findChild(decoration, "menuBar");
            verify(menuBar);

            keyPress(Qt.Key_Alt, Qt.NoModifier);
            tryCompare(menuLoader, "opacity", 1);
            tryCompare(titleLabel, "opacity", 0);

            keyRelease(Qt.Key_Alt, Qt.NoModifier);
            tryCompare(menuLoader, "opacity", 0);
            tryCompare(titleLabel, "opacity", 1);
        }

        function test_eatMouseEvents_data() {
            return [
                {tag: "left mouse click", signalName: "clicked", button: Qt.LeftButton },
                {tag: "right mouse click", signalName: "clicked", button: Qt.RightButton },
                {tag: "middle mouse click", signalName: "clicked", button: Qt.MiddleButton },
                {tag: "mouse wheel", signalName: "wheel", button: Qt.MiddleButton },
                {tag: "double click (LMB)", signalName: "doubleClicked", button: Qt.LeftButton },
                {tag: "double click (RMB)", signalName: "doubleClicked", button: Qt.RightButton },
            ]
        }

        function test_eatMouseEvents(data) {
            mouseEaterSpy.signalName = data.signalName;
            if (data.signalName === "wheel") {
                mouseWheel(decoration, decoration.width/2, decoration.height/2, 20, 20);
            } else if (data.signalName === "clicked") {
                mouseClick(decoration, decoration.width/2, decoration.height/2, data.button);
            } else {
                mouseDoubleClick(decoration, decoration.width/2, decoration.height/2, data.button);
            }

            tryCompare(mouseEaterSpy, "count", 0);
        }
    }
}
