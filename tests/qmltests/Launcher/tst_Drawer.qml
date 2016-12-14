/*
 * Copyright 2013-2016 Canonical Ltd.
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
import Ubuntu.Components 1.3
import ".."
import "../../../qml/Launcher"
import Unity.Launcher 0.1
import Utils 0.1 // For EdgeBarrierSettings
import Unity.Test 0.1

StyledItem {
    id: root
    theme.name: "Ubuntu.Components.Themes.SuruDark"

    width: units.gu(140)
    height: units.gu(70)
    Rectangle {
        anchors.fill: parent
        color: UbuntuColors.graphite // something neither white nor black
    }

    Launcher {
        id: launcher
        x: 0
        y: 0
        width: units.gu(40)
        height: root.height

        lockedVisible: lockedVisibleCheckBox.checked

        property string lastSelectedApplication
        onLauncherApplicationSelected: {
            lastSelectedApplication = appId
        }

        Component.onCompleted: {
            launcher.focus = true
            edgeBarrierControls.target = testCase.findChild(this, "edgeBarrierController");
        }
    }

    ColumnLayout {
        anchors { bottom: parent.bottom; right: parent.right; margins: units.gu(1) }
        spacing: units.gu(1)
        width: childrenRect.width

        RowLayout {
            CheckBox {
                id: lockedVisibleCheckBox
                checked: false
            }
            Label {
                text: "Launcher always visible"
            }
        }

        Slider {
            id: widthSlider
            Layout.fillWidth: true
            minimumValue: 6
            maximumValue: 12
            value: 10
        }

        MouseTouchEmulationCheckbox {}

        EdgeBarrierControls {
            id: edgeBarrierControls
            text: "Drag here to pull out launcher"
            onDragged: { launcher.pushEdge(amount); }
        }
    }

    UnityTestCase {
        id: testCase
        when: windowShown
        name: "Drawer"

        function dragDrawerIntoView() {
            var startX = launcher.dragAreaWidth/2;
            var startY = launcher.height/2;
            touchFlick(launcher,
                       startX, startY,
                       startX+units.gu(35), startY);

            var drawer = findChild(launcher, "drawer");
            verify(!!drawer);

            // wait until it gets fully extended
            // a tryCompare doesn't work since
            //    compare(-0.000005917593600024418, 0);
            // is true and in this case we want exactly 0 or will have pain later on
            tryCompareFunction( function(){ return drawer.x === 0; }, true );
            tryCompare(launcher, "state", "drawer");
            tryCompare(launcher, "drawerShown", true);
        }

        function revealByEdgePush() {
            // Place the mouse against the window/screen edge and push beyond the barrier threshold
            // If the mouse did not move between two revealByEdgePush(), we need it to move out the
            // area to make sure we're not just accumulating to the previous push
            mouseMove(root, root.width, root.height / 2);
            mouseMove(root, 1, root.height / 2);

            launcher.pushEdge(EdgeBarrierSettings.pushThreshold * 1.1);

            var drawer = findChild(launcher, "drawer");
            verify(!!drawer);

            // wait until it gets fully extended
            tryCompare(drawer, "x", 0);
            tryCompare(launcher, "state", "drawer");
            tryCompare(launcher, "drawerShown", true);
        }

        function init() {
            launcher.lastSelectedApplication = "";
            launcher.lockedVisible = false;
            launcher.hide();
            var drawer = findChild(launcher, "drawer");
            tryCompare(drawer, "x", -drawer.width);
        }

        function test_revealByEdgeDrag() {
            dragDrawerIntoView();
        }

        function test_revealByEdgePush_data() {
            return [
                { tag: "autohide launcher", autohide: true },
                { tag: "locked launcher", autohide: false }
            ]
        }

        function test_revealByEdgePush(data) {
            launcher.lockedVisible = !data.autohide;

            var panel = findChild(launcher, "launcherPanel");
            tryCompare(panel, "x", data.autohide ? -panel.width : 0);
            tryCompare(launcher, "state", data.autohide ? "" : "visible");
            waitForRendering(launcher)

            revealByEdgePush();
        }

        function test_hideByDraggingDrawer_data() {
            return [
                {tag: "autohide", autohide: true, endState: ""},
                {tag: "locked", autohide: false, endState: "visible"}
            ]
        }

        function test_hideByDraggingDrawer(data) {
            launcher.lockedVisible = !data.autohide;

            dragDrawerIntoView();
            waitForRendering(launcher);

            var drawer = findChild(launcher, "drawer");

            mouseFlick(root, drawer.width - units.gu(1), drawer.height / 2, units.gu(2), drawer.height / 2, true, true);

            tryCompare(drawer.anchors, "rightMargin", 0);
            tryCompare(launcher, "state", data.endState);
            launcher.lockedVisible = false;
        }

        function test_hideByClickingOutside() {
            dragDrawerIntoView();

            var drawer = findChild(launcher, "drawer");

            mouseClick(root, drawer.width + units.gu(1), root.height / 2);

            tryCompare(launcher, "state", "");
        }

        function test_launchAppFromDrawer() {
            dragDrawerIntoView();

            var drawerList = findChild(launcher, "drawerItemList");
            var dialerApp = findChild(drawerList, "drawerItem_dialer-app");
            mouseClick(dialerApp, dialerApp.width / 2, dialerApp.height / 2);

            tryCompare(launcher, "lastSelectedApplication", "dialer-app");

            tryCompare(launcher, "state", "");
        }

        function test_launcherGivesUpFocusAfterLaunchingFromDrawer() {
            dragDrawerIntoView();

            tryCompare(launcher, "focus", true);

            var drawerList = findChild(launcher, "drawerItemList");
            var dialerApp = findChild(drawerList, "drawerItem_dialer-app");
            mouseClick(dialerApp, dialerApp.width / 2, dialerApp.height / 2);

            tryCompare(launcher, "focus", false);
        }

        function test_drawerDisabled() {
            launcher.drawerEnabled = false;

            var startX = launcher.dragAreaWidth/2;
            var startY = launcher.height/2;
            touchFlick(launcher,
                       startX, startY,
                       startX+units.gu(35), startY);

            var drawer = findChild(launcher, "drawer");
            verify(!!drawer);

            tryCompare(launcher, "state", "visible");
            tryCompare(launcher, "drawerShown", false);

            launcher.drawerEnabled = true;
        }

        function test_search() {
            compare(launcher.lastSelectedApplication, "");

            launcher.openDrawer(true)
            typeString("cam");
            keyClick(Qt.Key_Enter);

            compare(launcher.lastSelectedApplication, "camera-app");
        }

        function test_dragDirectionOnLeftEdgeDrag_data() {
            return [
                { tag: "reveal", direction: "right", endState: "drawer" },
                { tag: "cancel", direction: "left", endState: "visible" },
            ]
        }

        function test_dragDirectionOnLeftEdgeDrag(data) {
            var startX = launcher.dragAreaWidth/2;
            var startY = launcher.height/2;
            var stopX = startX + units.gu(35);
            var endX = stopX + (units.gu(4) * (data.direction === "left" ? -1 : 1))

            touchFlick(launcher, startX, startY, stopX, startY, true, false);
            touchFlick(launcher, stopX, startY, endX, startY, false, true);

            tryCompare(launcher, "state", data.endState)
        }
    }
}
