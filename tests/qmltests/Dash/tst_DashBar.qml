/*
 * Copyright 2013 Canonical Ltd.
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
import QtTest 1.0
import Unity 0.1
import ".."
import "../../../qml/Dash"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    width: units.gu(40)
    height: units.gu(71)

    DashBar {
        id: dashBar

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: scopes
        onItemSelected: currentIndex = index
    }

    Scopes {
        id: scopes
    }

    SignalSpy {
        id: signalSpy
        signalName: "itemSelected"
        target: dashBar
    }

    UT.UnityTestCase {
        name: "DashBar"
        when: scopes.loaded

        property alias model: dashBar.model
        property alias currentIndex: dashBar.currentIndex

        readonly property alias lineHeight: dashBar.lineHeight
        readonly property alias itemSize: dashBar.itemSize
        readonly property alias iconSize: dashBar.iconSize
        readonly property var panel: findChild(dashBar, "panel");

        function initTestCase() {
            currentIndex = 2
        }

        function waitForAnimationToEnd() {
            compare(panel.animating, true) // check the animation started
            tryCompare(panel, "animating", false) // wait till the animation ends
        }

        function closePanel() {
            dashBar.finishNavigation()
            waitForAnimationToEnd()
            tryCompare(panel, "opened", false)
        }

        function openPanel() {
            dashBar.startNavigation()
            waitForAnimationToEnd()
            tryCompare(panel, "opened", true)
        }

        function test_navigationAndHide() {
            openPanel()
            closePanel()
        }

        function test_itemSelected() {
            openPanel()

            var row = findChild(dashBar, "row");
            tryCompareFunction(function(){return row.width > 0;}, true);
            for (var i = 0; i < model.rowCount(); i++) {
                // coordinate x in the middle of item with index 'i'
                var x = row.x + (row.width / model.rowCount()) * i + itemSize / 2

                // FIXME workaround for a bug in SignalSpy
                signalSpy.clear()

                // (item, x, y, button, modifiers, delay)
                mouseClick(panel, x, row.height / 2, Qt.LeftButton, Qt.NoModifier, 0)
                compare(signalSpy.count > 0, true, "signal itemSelected not triggered")
                compare(signalSpy.signalArguments[0][0], i, "signal itemSelected emitted unexpected index");
                tryCompare(dashBar, "currentIndex", i);
            }

            closePanel()
        }
    }
}
