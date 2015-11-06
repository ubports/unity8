/*
 * Copyright 2013-2014 Canonical Ltd.
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
import Ubuntu.Components 1.3
import ".."
import "../../../qml/Launcher"
import Unity.Launcher 0.1

/* Nothing is shown at first. If you drag from left edge you will bring up the
   launcher. */
Item {
    id: root
    width: units.gu(50)
    height: units.gu(55)

    Loader {
        id: launcherLoader
        anchors.fill: parent
        property bool itemDestroyed: false
        sourceComponent: Component {
            Launcher {
                id: launcher
                x: 0
                y: 0
                width: units.gu(40)
                height: root.height

                property string lastSelectedApplication

                onLauncherApplicationSelected: {
                    lastSelectedApplication = appId
                }

                property int showDashHome_count: 0
                onShowDashHome: {
                    showDashHome_count++;
                }

                property int maxPanelX: 0

                Connections {
                    target: testCase.findChild(launcher, "launcherPanel")

                    onXChanged: {
                        if (target.x > launcher.maxPanelX) {
                            launcher.maxPanelX = target.x;
                        }
                    }
                }

                Component.onCompleted: {
                    launcherLoader.itemDestroyed = false;
                }
                Component.onDestruction: {
                    launcherLoader.itemDestroyed = true;
                }
            }
        }
    }

    ColumnLayout {
        anchors { bottom: parent.bottom; right: parent.right; margins: units.gu(1) }
        spacing: units.gu(1)
        width: childrenRect.width

        MouseTouchEmulationCheckbox {}

        Button {
            text: "emit hinting signal"
            onClicked: LauncherModel.emitHint()
            Layout.fillWidth: true
        }

        Button {
            text: "rotate"
            onClicked: launcherLoader.item.inverted = !launcherLoader.item.inverted
            Layout.fillWidth: true
        }

        Row {
            spacing: units.gu(1)

            Button {
                text: "35% bar"
                onClicked: LauncherModel.setProgress(LauncherModel.get(parseInt(appIdEntryBar.displayText)).appId, 35)
                Layout.fillWidth: true
            }

            TextArea {
                id: appIdEntryBar
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(4)
                height: units.gu(4)
                autoSize: true
                text: "2"
                maximumLineCount: 1
            }

            Button {
                text: "no bar"
                onClicked: LauncherModel.setProgress(LauncherModel.get(parseInt(appIdEntryBar.displayText)).appId, -1)
                Layout.fillWidth: true
            }
        }

        Row {
            spacing: units.gu(1)

            Button {
                text: "set alert"
                onClicked: LauncherModel.setAlerting(LauncherModel.get(parseInt(appIdEntryAlert.displayText)).appId, true)
            }

            TextArea {
                id: appIdEntryAlert
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(5)
                height: units.gu(4)
                autoSize: true
                text: "2"
                maximumLineCount: 1
                Layout.fillWidth: true
            }

            Button {
                text: "unset alert"
                onClicked: LauncherModel.setAlerting(LauncherModel.get(parseInt(appIdEntryAlert.displayText)).appId, false)
            }
        }
    }

    SignalSpy {
        id: signalSpy
        target: LauncherModel
    }

    UnityTestCase {
        id: testCase
        name: "Launcher"
        when: windowShown

        property Item launcher: launcherLoader.status === Loader.Ready ? launcherLoader.item : null
        function cleanup() {
            launcherLoader.active = false;
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(launcherLoader, "itemDestroyed", true);
            launcherLoader.active = true;
        }
        function init() {
            // Make sure we don't start the test with the mouse hovering the launcher
            mouseMove(root, root.width, root.height / 2);

            var listView = findChild(launcher, "launcherListView");
            // wait for it to settle before doing the flick. Otherwise the flick
            // might fail.
            // On startup that listView is already moving. maybe because of its contents
            // growing while populating it with icons etc.
            tryCompare(listView, "flicking", false);

            // Make sure noone changed the height of the window. The issue this test case
            // is verifying only happens on certain heights of the Launcher
            compare(root.height, units.gu(55));

            compare(listView.contentY, -listView.topMargin, "Launcher did not start up with first item unfolded");

            // Now do check that snapping is in fact enabled
            compare(listView.snapMode, ListView.SnapToItem, "Snapping is not enabled");
        }

        function dragLauncherIntoView() {
            var startX = launcher.dragAreaWidth/2;
            var startY = launcher.height/2;
            touchFlick(launcher,
                       startX, startY,
                       startX+units.gu(8), startY);

            var panel = findChild(launcher, "launcherPanel");
            verify(!!panel);

            // wait until it gets fully extended
            // a tryCompare doesn't work since
            //    compare(-0.000005917593600024418, 0);
            // is true and in this case we want exactly 0 or will have pain later on
            tryCompareFunction( function(){ return panel.x === 0; }, true );
            tryCompare(launcher, "state", "visible");
        }

        function revealByHover() {
            mouseMove(root, 1, root.height / 2);

            var panel = findChild(launcher, "launcherPanel");
            verify(!!panel);

            // wait until it gets fully extended
            tryCompare(panel, "x", 0);
            tryCompare(launcher, "state", "visibleTemporary");
        }

        function waitUntilLauncherDisappears() {
            var panel = findChild(launcher, "launcherPanel");
            tryCompare(panel, "x", -panel.width, 1000);
        }

        function waitForWiggleToStart(appIcon) {
            verify(appIcon != undefined)
            tryCompare(appIcon, "wiggling", true, 1000, "wiggle-anim should not be in stopped state")
        }

        function waitForWiggleToStop(appIcon) {
            verify(appIcon != undefined)
            tryCompare(appIcon, "wiggling", false, 1000, "wiggle-anim should not be in running state")
        }

        function positionLauncherListAtBeginning() {
            var listView = testCase.findChild(launcherLoader.item, "launcherListView");
            listView.contentY = -listView.topMargin;
        }
        function positionLauncherListAtEnd() {
            var listView = testCase.findChild(launcherLoader.item, "launcherListView");
            if ((listView.contentHeight + listView.topMargin + listView.bottomMargin) > listView.height) {
                listView.contentY = listView.topMargin + listView.contentHeight
                    - listView.height;
            }
        }

        // Drag from the left edge of the screen rightwards and check that the launcher
        // appears (as if being dragged by the finger/pointer)
        function test_dragLeftEdgeToRevealLauncherAndTapCenterToDismiss() {
            waitUntilLauncherDisappears();

            var panel = findChild(launcher, "launcherPanel")
            verify(!!panel)

            // it starts out hidden just left of the left launcher edge
            compare(panel.x, -panel.width)

            dragLauncherIntoView()

            // tapping on the center of the screen should dismiss the launcher
            mouseClick(launcher)

            // should eventually get fully retracted (hidden)
            tryCompare(panel, "x", -launcher.panelWidth, 1000)
        }

        /* If I click on the icon of an application on the launcher
           Launcher::launcherApplicationSelected signal should be emitted with the
           corresponding desktop file. E.g. clicking on phone icon should yield
           launcherApplicationSelected("[...]dialer-app.desktop") */
        function test_clickingOnAppIconCausesSignalEmission_data() {
            return [
                {tag: "by mouse", mouse: true},
                {tag: "by touch", mouse: false}
            ]
        }

        function test_clickingOnAppIconCausesSignalEmission(data) {
            if (data.mouse) {
                revealByHover();
            } else {
                dragLauncherIntoView();
            }
            launcher.lastSelectedApplication = "";
            launcher.inverted = false;

            positionLauncherListAtBeginning();

            var appIcon = findChild(launcher, "launcherDelegate0");

            verify(!!appIcon);

            if (data.mouse) {
                mouseClick(appIcon);
            } else {
                tap(appIcon);
            }

            tryCompare(launcher, "lastSelectedApplication",
                       appIcon.appId);

            // Tapping on an application icon also dismisses the launcher
            waitUntilLauncherDisappears();
        }

        /* If I click on the dash icon on the launcher
           Launcher::showDashHome signal should be emitted */
        function test_clickingOnDashIconCausesSignalEmission() {
            launcher.showDashHome_count = 0

            dragLauncherIntoView()

            var dashIcon = findChild(launcher, "dashItem")
            verify(!!dashIcon)

            mouseClick(dashIcon)

            tryCompare(launcher, "showDashHome_count", 1)

            // Tapping on the dash icon also dismisses the launcher
            waitUntilLauncherDisappears()
        }

        function test_teaseLauncher_data() {
            return [
                {tag: "available", available: true},
                {tag: "not available", available: false}
            ];
        }

        function test_teaseLauncher(data) {
            launcher.available = data.available;
            launcher.maxPanelX = -launcher.panelWidth;
            launcher.tease();

            if (data.available) {
                // Check if the launcher slides in for units.gu(2). However, as the animation is 200ms
                // and the teaseTimer's timeout too, give it a 2 pixels grace distance
                tryCompareFunction(
                    function(){
                        return launcher.maxPanelX >= -launcher.panelWidth + units.gu(2) - 2;
                    },
                    true)
            } else {
                wait(100)
                compare(launcher.maxPanelX, -launcher.panelWidth, "Launcher moved even if it shouldn't")
            }
            waitUntilLauncherDisappears();
            launcher.available = true;
        }

        function test_hintLauncherOnChange() {
            var launcherPanel = findChild(launcher, "launcherPanel")
            // Make sure we start hidden
            tryCompare(launcherPanel, "x", -launcher.panelWidth)
            // reset our measurement property
            launcher.maxPanelX = -launcher.panelWidth
            // change it
            LauncherModel.move(0, 1)
            LauncherModel.emitHint();

            // make sure it opened fully and hides again without delay
            tryCompare(launcher, "maxPanelX", 0)
            tryCompare(launcherPanel, "x", -launcher.panelWidth, 1000)
        }

        function test_countEmblems() {
            dragLauncherIntoView();
            var launcherListView = findChild(launcher, "launcherListView");
            for (var i = 0; i < launcherListView.count; ++i) {
                var delegate = findChild(launcherListView, "launcherDelegate" + i)
                compare(findChild(delegate, "countEmblem").visible, LauncherModel.get(i).countVisible)
                // Intentionally allow type coercion (string/number)
                compare(findChild(delegate, "countLabel").text == LauncherModel.get(i).count, true)
            }
        }

        function test_progressOverlays() {
            dragLauncherIntoView();
            var launcherListView = findChild(launcher, "launcherListView");
            for (var i = 0; i < launcherListView.count; ++i) {
                var delegate = findChild(launcherListView, "launcherDelegate" + i)
                compare(findChild(delegate, "progressOverlay").visible, LauncherModel.get(i).progress >= 0)
            }
        }

        function test_runningHighlight() {
            dragLauncherIntoView();
            var launcherListView = findChild(launcher, "launcherListView");
            for (var i = 0; i < launcherListView.count; ++i) {
                var delegate = findChild(launcherListView, "launcherDelegate" + i)
                compare(findChild(delegate, "runningHighlight").visible, LauncherModel.get(i).running)
            }
        }

        function test_focusedHighlight() {
            dragLauncherIntoView();
            var launcherListView = findChild(launcher, "launcherListView");
            for (var i = 0; i < launcherListView.count; ++i) {
                var delegate = findChild(launcherListView, "launcherDelegate" + i)
                compare(findChild(delegate, "focusedHighlight").visible, LauncherModel.get(i).focused)
            }
        }

        function test_clickFlick_data() {
            var listView = findChild(launcher, "launcherListView");
            return [
                {tag: "unfolded top", positionViewAtBeginning: true,
                                      clickY: listView.topMargin + units.gu(2),
                                      expectFlick: false},

                {tag: "folded top", positionViewAtBeginning: false,
                                    clickY: listView.topMargin + units.gu(2),
                                    expectFlick: true},

                {tag: "unfolded bottom", positionViewAtBeginning: false,
                                         clickY: listView.height - listView.topMargin - units.gu(1),
                                         expectFlick: false},

                {tag: "folded bottom", positionViewAtBeginning: true,
                                       clickY: listView.height - listView.topMargin - units.gu(1),
                                       expectFlick: true},
            ];
        }

        function test_clickFlick(data) {
            launcher.inverted = false;
            launcher.lastSelectedApplication = "";
            dragLauncherIntoView();
            var listView = findChild(launcher, "launcherListView");

            // flicking is unreliable. sometimes it works, sometimes the
            // list view moves just a tiny bit or not at all, making tests fail.
            // So for stability's sake we just put the listView in the position
            // we want to to actually start doing what this tests intends to check.
            if (data.positionViewAtBeginning) {
                positionLauncherListAtBeginning();
            } else {
                positionLauncherListAtEnd();
            }
            tryCompare(listView, "flicking", false);

            var oldY = listView.contentY;

            mouseClick(listView, listView.width / 2, data.clickY);
            tryCompare(listView, "flicking", false);

            if (data.expectFlick) {
                verify(listView.contentY != oldY);
                compare(launcher.lastSelectedApplication, "", "Launcher app clicked signal emitted even though it should only flick");
            } else {
                verify(launcher.lastSelectedApplication != "");
                compare(listView.contentY, oldY, "Launcher was flicked even though it should only launch an app");
            }
        }

        function test_dragndrop_data() {
            return [
                {tag: "startDrag", fullDrag: false },
                {tag: "fullDrag horizontal", fullDrag: true, orientation: ListView.Horizontal },
                {tag: "fullDrag vertical", fullDrag: true, orientation: ListView.Vertical },
            ];
        }

        function test_dragndrop(data) {
            dragLauncherIntoView();
            var draggedItem = findChild(launcher, "launcherDelegate4")
            var item0 = findChild(launcher, "launcherDelegate0")
            var fakeDragItem = findChild(launcher, "fakeDragItem")
            var initialItemHeight = draggedItem.height
            var item4 = LauncherModel.get(4).appId
            var item3 = LauncherModel.get(3).appId

            var listView = findChild(launcher, "launcherListView");
            listView.flick(0, units.gu(200));
            tryCompare(listView, "flicking", false);

            // Initial state
            compare(draggedItem.itemOpacity, 1, "Item's opacity is not 1 at beginning")
            compare(fakeDragItem.visible, false, "FakeDragItem isn't invisible at the beginning")
            tryCompare(findChild(draggedItem, "dropIndicator"), "opacity", 0)

            // Doing longpress
            var mouseOnLauncher = launcher.mapFromItem(draggedItem, draggedItem.width / 2, draggedItem.height / 2)
            var currentMouseX = mouseOnLauncher.x
            var currentMouseY = mouseOnLauncher.y
            var newMouseX = currentMouseX
            var newMouseY = currentMouseY
            mousePress(launcher, currentMouseX, currentMouseY)
            // DraggedItem needs to hide and fakeDragItem become visible
            tryCompare(draggedItem, "itemOpacity", 0)
            tryCompare(fakeDragItem, "visible", true)

            // Dragging a bit (> 1.5 gu)
            newMouseX -= units.gu(2)
            mouseFlick(launcher, currentMouseX, currentMouseY, newMouseX, newMouseY, false, false, 100)
            currentMouseX = newMouseX

            // Other items need to expand and become 0.6 opaque
            tryCompare(item0, "angle", 0)
            tryCompare(item0, "itemOpacity", 0.6)

            if (data.fullDrag) {
                // Dragging a bit more
                if (data.orientation == ListView.Horizontal) {
                    newMouseX += units.gu(15)
                    mouseFlick(launcher, currentMouseX, currentMouseY, newMouseX, newMouseY, false, false, 100)
                    currentMouseX = newMouseX

                    tryCompare(findChild(draggedItem, "dropIndicator"), "opacity", 1)
                    tryCompare(draggedItem, "height", units.gu(1))

                    // Dragging downwards. Item needs to move in the model
                    newMouseY -= initialItemHeight * 1.5
                    mouseFlick(launcher, currentMouseX, currentMouseY, newMouseX, newMouseY, false, false, 100)
                    currentMouseY = newMouseY
                } else if (data.orientation == ListView.Vertical) {
                    newMouseY -= initialItemHeight * 1.5
                    mouseFlick(launcher, currentMouseX, currentMouseY, newMouseX, newMouseY, false, false, 100)
                    currentMouseY = newMouseY

                    tryCompare(findChild(draggedItem, "dropIndicator"), "opacity", 1)
                    tryCompare(draggedItem, "height", units.gu(1))
                }

                waitForRendering(draggedItem)
                compare(LauncherModel.get(4).appId, item3)
                compare(LauncherModel.get(3).appId, item4)
            }

            // Releasing and checking if initial values are restored
            mouseRelease(launcher)
            tryCompare(findChild(draggedItem, "dropIndicator"), "opacity", 0)
            tryCompare(draggedItem, "itemOpacity", 1)
            tryCompare(fakeDragItem, "visible", false)

            // Click somewhere in the empty space to make it hide in case it isn't
            mouseClick(launcher, launcher.width - units.gu(1), units.gu(1));
            waitUntilLauncherDisappears();
        }

        function test_dragndrop_cancel_data() {
            return [
                {tag: "by mouse", mouse: true},
                {tag: "by touch", mouse: false}
            ]
        }

        function test_dragndrop_cancel(data) {
            dragLauncherIntoView();
            var draggedItem = findChild(launcher, "launcherDelegate4")
            var item0 = findChild(launcher, "launcherDelegate0")
            var fakeDragItem = findChild(launcher, "fakeDragItem")

            // Doing longpress
            var currentMouseX = draggedItem.width / 2
            var currentMouseY = draggedItem.height / 2

            if(data.mouse) {
                mousePress(draggedItem, currentMouseX, currentMouseY)
            } else {
                touchPress(draggedItem, currentMouseX, currentMouseY)
            }

            // DraggedItem needs to hide and fakeDragItem become visible
            tryCompare(draggedItem, "itemOpacity", 0)
            tryCompare(fakeDragItem, "visible", true)

            // Dragging
            currentMouseX -= units.gu(20)

            if(data.mouse) {
                mouseMove(draggedItem, currentMouseX, currentMouseY)
            } else {
                touchMove(draggedItem, currentMouseX, currentMouseY)
            }

            // Make sure we're in the dragging state
            var dndArea = findChild(launcher, "dndArea");
            tryCompare(draggedItem, "dragging", true)
            tryCompare(dndArea, "draggedIndex", 4)

            // Click/Tap somewhere in the middle of the screen to close/hide the launcher
            if(data.mouse) {
                mouseClick(root)
            } else {
                tap(root)
            }

            // Make sure the dnd operation has been stopped
            tryCompare(draggedItem, "dragging", false)
            tryCompare(dndArea, "draggedIndex", -1)
            tryCompare(dndArea, "drag.target", undefined)
        }

        function test_quicklist_dismiss() {
            dragLauncherIntoView();
            var draggedItem = findChild(launcher, "launcherDelegate5")
            var item0 = findChild(launcher, "launcherDelegate0")
            var fakeDragItem = findChild(launcher, "fakeDragItem")
            var quickListShape = findChild(launcher, "quickListShape")

            // Initial state
            compare(quickListShape.visible, false)

            // Doing longpress
            mousePress(draggedItem)
            tryCompare(fakeDragItem, "visible", true) // Wait longpress happening
            tryCompare(quickListShape, "visible", true)

            // Dragging a bit (> 1.5 gu)
            mouseMove(draggedItem, -units.gu(2), draggedItem.height / 2)

            // QuickList needs to be closed when a drag operation starts
            tryCompare(quickListShape, "visible", false)

            mouseRelease(draggedItem);
        }

        function test_quicklist_positioning_data() {
            return [
                {tag: "top", flickTo: "top", itemIndex: 0},
                {tag: "bottom", flickTo: "bottom", itemIndex: 9}
            ];
        }

        function test_quicklist_positioning(data) {
            dragLauncherIntoView();
            var quickList = findChild(launcher, "quickList")
            var draggedItem = findChild(launcher, "launcherDelegate" + data.itemIndex)
            var quickListShape = findChild(launcher, "quickListShape")

            // Position launcher to where we need it
            var listView = findChild(launcher, "launcherListView");
            if (data.flickTo == "top") {
                positionLauncherListAtBeginning();
            } else {
                positionLauncherListAtEnd();
            }

            // Doing longpress
            mousePress(draggedItem);
            tryCompare(quickListShape, "opacity", 0.8);
            mouseRelease(draggedItem);

            verify(quickList.y >= units.gu(1));
            verify(quickList.y + quickList.height + units.gu(1) <= launcher.height);
            compare(quickList.width, units.gu(30));

            // Click somewhere in the empty space to dismiss the quicklist
            mouseClick(launcher, launcher.width - units.gu(1), units.gu(1));
            tryCompare(quickListShape, "visible", false);

            // Click somewhere in the empty space to dismiss the launcher
            mouseClick(launcher, launcher.width - units.gu(1), units.gu(1));
            waitUntilLauncherDisappears();
        }

        function test_quicklist_click_data() {
            return [
                {tag: "non-clickable", index: 1, clickable: false },
                {tag: "clickable", index: 2, clickable: true },
            ];
        }

        function test_quicklist_click(data) {
            dragLauncherIntoView();
            var clickedItem = findChild(launcher, "launcherDelegate5")
            var quickList = findChild(launcher, "quickList")
            var quickListShape = findChild(launcher, "quickListShape")

            // Initial state
            tryCompare(quickListShape, "visible", false)

            // Doing longpress
            mousePress(clickedItem)
            tryCompare(clickedItem, "itemOpacity", 0) // Wait for longpress to happen
            verify(quickListShape.visible, "QuickList must be visible")

            mouseRelease(clickedItem);

            var quickListEntry = findChild(quickList, "quickListEntry" + data.index)

            signalSpy.clear();
            signalSpy.signalName = "quickListTriggered"

            mouseClick(quickListEntry)

            if (data.clickable) {
                // QuickList needs to be closed when some clickable item is clicked
                tryCompare(quickListShape, "visible", false)

                compare(signalSpy.count, 1, "Quicklist signal wasn't triggered")
                compare(signalSpy.signalArguments[0][0], LauncherModel.get(5).appId)
                compare(signalSpy.signalArguments[0][1], 2)

            } else {

                // QuickList must not be closed when a non-clickable item is clicked
                verify(quickListShape.visible, "QuickList must be visible")

                compare(signalSpy.count, 0, "Quicklist signal must NOT be triggered when clicking a non-clickable item")

                // Click somewhere in the empty space to dismiss the quicklist
                mouseClick(launcher, launcher.width - units.gu(1), units.gu(1));
                tryCompare(quickListShape, "visible", false)
            }
        }

        function test_quicklistHideOnLauncherHide() {
            dragLauncherIntoView();
            var clickedItem = findChild(launcher, "launcherDelegate5")
            var quickList = findChild(launcher, "quickList")

            // Initial state
            tryCompare(quickList, "state", "")

            // Doing longpress
            mousePress(clickedItem)
            tryCompare(clickedItem, "itemOpacity", 0) // Wait for longpress to happen
            verify(quickList, "state", "open")

            launcher.hide();

            tryCompare(quickList, "state", "");
        }

        function test_quickListMenuOnRMB() {
            dragLauncherIntoView();
            var clickedItem = findChild(launcher, "launcherDelegate5")
            var quickList = findChild(launcher, "quickList")
            var quickListShape = findChild(launcher, "quickListShape")
            var dndArea = findChild(launcher, "dndArea");

            // Initial state
            tryCompare(quickListShape, "visible", false)

            // Doing RMB click
            mouseClick(clickedItem, clickedItem.width / 2, clickedItem.height / 2, Qt.RightButton)
            tryCompare(quickListShape, "visible", true)
            verify(quickList, "state", "open")
            verify(dndArea, "dragging", false)

            // Click somewhere in the empty space to dismiss the quicklist
            mouseClick(launcher, launcher.width - units.gu(1), units.gu(1));
            tryCompare(quickListShape, "visible", false);
            verify(quickList, "state", "")
        }

        function test_revealByHover() {
            var panel = findChild(launcher, "launcherPanel");
            verify(!!panel);

            revealByHover();
            tryCompare(launcher, "state", "visibleTemporary");

            // Now move the mouse away and make sure it hides in less than a second
            mouseMove(root, root.width, root.height / 2)

            tryCompare(launcher, "state", "", 1000, "Launcher didn't hide after moving mouse away from it");
            waitUntilLauncherDisappears();
        }

        function test_progressChangeViaModel() {
            dragLauncherIntoView();
            var item = findChild(launcher, "launcherDelegate0")
            verify(item != undefined)
            LauncherModel.setProgress(LauncherModel.get(0).appId, -1)
            compare(findChild(item, "progressOverlay").visible, false)
            LauncherModel.setProgress(LauncherModel.get(0).appId, 20)
            compare(findChild(item, "progressOverlay").visible, true)
            LauncherModel.setProgress(LauncherModel.get(0).appId, 0)
        }

        function test_alertPeekingIcon() {
            var listView = findChild(launcher, "launcherListView")
            verify(listView != undefined)
            LauncherModel.setAlerting(LauncherModel.get(5).appId, true)
            tryCompare(listView, "peekingIndex", 5, 1000, "Wrong appId set as peeking-index")
            LauncherModel.setAlerting(LauncherModel.get(5).appId, false)
            tryCompare(listView, "peekingIndex", -1, 1000, "peeking-index should be -1")
        }

        function test_alertHidingIcon() {
            var listView = findChild(launcher, "launcherListView")
            verify(listView != undefined)
            var appIcon6 = findChild(launcher, "launcherDelegate6")
            verify(appIcon6 != undefined)
            LauncherModel.setAlerting(LauncherModel.get(6).appId, true)
            waitForWiggleToStart(appIcon6)
            LauncherModel.setAlerting(LauncherModel.get(6).appId, false)
            waitForWiggleToStop(appIcon6)
            tryCompare(appIcon6, "x", 0, 1000, "x-value of appId #6 should not be non-zero")
            waitForRendering(listView)
        }

        function test_alertIgnoreFocusedApp() {
            LauncherModel.setAlerting(LauncherModel.get(0).appId, true)
            compare(LauncherModel.get(0).alerting, false, "Focused app should not have the alert-state set")
        }

        function test_alertOnlyOnePeekingIcon() {
            var listView = findChild(launcher, "launcherListView")
            verify(listView != undefined)
            LauncherModel.setAlerting(LauncherModel.get(3).appId, true)
            LauncherModel.setAlerting(LauncherModel.get(1).appId, true)
            LauncherModel.setAlerting(LauncherModel.get(5).appId, true)
            tryCompare(listView, "peekingIndex", 3, 1000, "Wrong appId set as peeking-index")
            LauncherModel.setAlerting(LauncherModel.get(1).appId, false)
            LauncherModel.setAlerting(LauncherModel.get(3).appId, false)
            LauncherModel.setAlerting(LauncherModel.get(5).appId, false)
            tryCompare(listView, "peekingIndex", -1, 1000, "peeking-index should be -1")
            waitForRendering(listView)
        }

        function test_alertMultipleApps() {
            LauncherModel.setAlerting(LauncherModel.get(1).appId, true)
            LauncherModel.setAlerting(LauncherModel.get(3).appId, true)
            LauncherModel.setAlerting(LauncherModel.get(5).appId, true)
            LauncherModel.setAlerting(LauncherModel.get(7).appId, true)
            compare(LauncherModel.get(1).alerting, true, "Alert-state of appId #1 should not be false")
            compare(LauncherModel.get(3).alerting, true, "Alert-state of appId #3 should not be false")
            compare(LauncherModel.get(5).alerting, true, "Alert-state of appId #5 should not be false")
            compare(LauncherModel.get(7).alerting, true, "Alert-state of appId #7 should not be false")
            LauncherModel.setAlerting(LauncherModel.get(1).appId, false)
            LauncherModel.setAlerting(LauncherModel.get(3).appId, false)
            LauncherModel.setAlerting(LauncherModel.get(5).appId, false)
            LauncherModel.setAlerting(LauncherModel.get(7).appId, false)
            compare(LauncherModel.get(1).alerting, false, "Alert-state of appId #1 should not be true")
            compare(LauncherModel.get(3).alerting, false, "Alert-state of appId #1 should not be true")
            compare(LauncherModel.get(5).alerting, false, "Alert-state of appId #1 should not be true")
            compare(LauncherModel.get(7).alerting, false, "Alert-state of appId #1 should not be true")
        }

        function test_alertMoveIconIntoView() {
            dragLauncherIntoView();
            var appIcon1 = findChild(launcher, "launcherDelegate1");
            var appIcon7 = findChild(launcher, "launcherDelegate7");
            LauncherModel.setAlerting(LauncherModel.get(1).appId, true)
            tryCompare(appIcon1, "angle", 0, 1000, "angle of appId #1 should not be non-zero")
            waitForWiggleToStart(appIcon1)
            LauncherModel.setAlerting(LauncherModel.get(7).appId, true)
            tryCompare(appIcon7, "angle", 0, 1000, "angle of appId #7 should not be non-zero")
            waitForWiggleToStart(appIcon7)
            LauncherModel.setAlerting(LauncherModel.get(1).appId, false)
            waitForWiggleToStop(appIcon1)
            LauncherModel.setAlerting(LauncherModel.get(7).appId, false)
            waitForWiggleToStop(appIcon7)
        }

        function test_alertWigglePeekDrag() {
            var appIcon5 = findChild(launcher, "launcherDelegate5");
            var listView = findChild(launcher, "launcherListView")
            verify(listView != undefined)
            LauncherModel.setAlerting(LauncherModel.get(5).appId, true)
            tryCompare(listView, "peekingIndex", 5, 1000, "Wrong appId set as peeking-index")
            waitForWiggleToStart(appIcon5)
            tryCompare(appIcon5, "wiggling", true, 1000, "appId #6 should not be still")
            dragLauncherIntoView();
            tryCompare(listView, "peekingIndex", -1, 1000, "peeking-index should be -1")
            LauncherModel.setAlerting(LauncherModel.get(5).appId, false)
            waitForWiggleToStop(appIcon5)
            tryCompare(appIcon5, "wiggling", false, 1000, "appId #1 should not be wiggling")
        }

        function test_alertViaCountAndCountVisible() {
            dragLauncherIntoView();
            var appIcon1 = findChild(launcher, "launcherDelegate1")
            var oldCount = LauncherModel.get(1).count
            LauncherModel.setCount(LauncherModel.get(1).appId, 42)
            tryCompare(appIcon1, "wiggling", false, 1000, "appId #1 should be still")
            LauncherModel.setCountVisible(LauncherModel.get(1).appId, 1)
            tryCompare(appIcon1, "wiggling", true, 1000, "appId #1 should not be still")
            LauncherModel.setAlerting(LauncherModel.get(1).appId, false)
            waitForWiggleToStop(appIcon1)
            LauncherModel.setCount(LauncherModel.get(1).appId, 4711)
            tryCompare(appIcon1, "wiggling", true, 1000, "appId #1 should not be still")
            LauncherModel.setAlerting(LauncherModel.get(1).appId, false)
            waitForWiggleToStop(appIcon1)
            LauncherModel.setCountVisible(LauncherModel.get(1).appId, 0)
            LauncherModel.setCount(LauncherModel.get(1).appId, oldCount)
        }
    }
}
