/*
 * Copyright 2013-2015 Canonical Ltd.
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
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Application 0.1
import QMenuModel 0.1
import Ubuntu.Telephony 0.1 as Telephony
import AccountsService 0.1
import Unity.InputInfo 0.1
import "../../../qml/Panel"
import "../../../qml/Components/PanelState"
import "../Stage"
import ".."

PanelTest {
    id: root
    width: units.gu(120)
    height: units.gu(71)
    color: "black"

    Binding {
        target: QuickUtils
        property: "keyboardAttached"
        value: keyboardAttached.checked
    }

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    Component.onCompleted: {
        theme.name = "Ubuntu.Components.Themes.SuruDark"
    }

    Rectangle {
        anchors.fill: parent
        color: "darkgrey"
    }

    SignalSpy {
        id: aboutToShowCalledSpy
        signalName: "aboutToShowCalled"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        clip: true

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            id: itemArea
            color: backgroundMouseArea.pressed ? "red" : "blue"

            MouseArea {
                id: backgroundMouseArea
                anchors.fill: parent
                hoverEnabled: true

                Panel {
                    id: panel
                    anchors.fill: parent
                    mode: modeSelector.model[modeSelector.selectedIndex]

                    indicatorMenuWidth: parent.width > units.gu(60) ? units.gu(40) : parent.width
                    applicationMenuWidth: parent.width > units.gu(60) ? units.gu(40) : parent.width

                    applicationMenus {
                        model: UnityMenuModel {
                            modelData: appMenuData.generateTestData(5, 4, 2, 3, "menu")
                        }

                        hides: [ panel.indicators ]
                    }

                    indicators {
                        model: root.indicatorsModel
                        hides: [ panel.applicationMenus ]
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            ListItem.ItemSelector {
                id: modeSelector
                anchors { left: parent.left; right: parent.right }
                activeFocusOnPress: false
                text: "Mode"
                model: ["staged", "windowed" ]
                onSelectedIndexChanged: {
                    panel.mode = model[selectedIndex];
                    keyboardAttached.checked = panel.mode == "windowed"
                }
            }

            Button {
                Layout.fillWidth: true
                text: panel.indicators.shown ? "Hide" : "Show"
                onClicked: {
                    if (panel.indicators.shown) {
                        panel.indicators.hide();
                    } else {
                        panel.indicators.show();
                    }
                }
            }

            Button {
                text: panel.fullscreenMode ? "Maximize" : "FullScreen"
                Layout.fillWidth: true
                onClicked: panel.fullscreenMode = !panel.fullscreenMode
            }

            Button {
                Layout.fillWidth: true
                text: callManager.hasCalls ? "Called" : "No Calls"
                onClicked: {
                    if (callManager.foregroundCall) {
                        callManager.foregroundCall = null;
                    } else {
                        callManager.foregroundCall = phoneCall;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: windowControlsCB
                    onClicked: PanelState.decorationsVisible = checked
                }
                Label {
                    text: "Show window decorations"
                    color: "white"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    onClicked: PanelState.title = checked ? "Fake window title" : ""
                }
                Label {
                    text: "Show fake window title"
                    color: "white"
                }
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            Repeater {
                model: root.originalModelData
                RowLayout {
                    CheckBox {
                        checked: true
                        onCheckedChanged: checked ? insertIndicator(index) : removeIndicator(index);
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData["identifier"]
                        color: "white"
                    }

                    CheckBox {
                        checked: true
                        onCheckedChanged: setIndicatorVisible(index, checked);
                    }
                    Label {
                        text: "visible"
                        color: "white"
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            MouseTouchEmulationCheckbox {
                id: mouseEmulation
                color: "white"
                checked: panel.mode == "staged"
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: keyboardAttached
                }
                Label {
                    text: "Keyboard Attached"
                    color: "white"
                }
            }
        }
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    UnityTestCase {
        name: "Panel"
        when: windowShown

        SignalSpy {
            id: backgroundPressedSpy
            target: backgroundMouseArea
            signalName: "pressedChanged"
        }

        SignalSpy {
            id: windowControlButtonsSpy
            target: PanelState
            signalName: "closeClicked"
        }

        function init() {
            panel.mode = "staged";
            mouseEmulation.checked = true;
            panel.fullscreenMode = false;
            callManager.foregroundCall = null;

            PanelState.title = "";
            PanelState.decorationsVisible = false;

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            var panelArea = findChild(panel, "panelArea");
            tryCompare(panelArea, "y", 0);

            backgroundPressedSpy.clear();
            compare(backgroundPressedSpy.valid, true);
            windowControlButtonsSpy.clear();
            compare(windowControlButtonsSpy.valid, true);

            waitForRendering(panel);
        }

        function cleanup() {
            panel.hasKeyboard = false;
            panel.indicators.hide();
            panel.applicationMenus.hide();
            waitForAllAnimationToComplete("initial");
        }

        function get_indicator_item(index) {
            var indicatorItem = findChild(panel, root.originalModelData[index]["identifier"]+"-panelItem");
            verify(indicatorItem !== null);

            return indicatorItem;
        }

        function waitForAllAnimationToComplete(state) {

            waitUntilTransitionsEnd(panel);
            tryCompare(panel.indicators.hideAnimation, "running", false);
            tryCompare(panel.indicators.showAnimation, "running", false);
            tryCompare(panel.indicators, "state", state);

            for (var i = 0; i < root.originalModelData.length; i++) {
                var indicatorItem = get_indicator_item(i);

                var itemState = findInvisibleChild(indicatorItem, "indicatorItemState");
                verify(itemState !== null);

                waitUntilTransitionsEnd(itemState);
            }

            tryCompare(panel.applicationMenus.hideAnimation, "running", false);
            tryCompare(panel.applicationMenus, "state", state);
        }

        function pullDownIndicatorsMenu() {
            var showDragHandle = findChild(panel.indicators, "showDragHandle");
            touchFlick(showDragHandle,
                       showDragHandle.width / 2,
                       showDragHandle.height / 2,
                       showDragHandle.width / 2,
                       showDragHandle.height / 2 + (showDragHandle.autoCompleteDragThreshold * 1.1));
            tryCompare(panel.indicators, "fullyOpened", true);
        }

        function pullDownApplicationsMenu(xPos) {
            var showDragHandle = findChild(panel.applicationMenus, "showDragHandle");
            if (xPos === undefined) {
                xPos = showDragHandle.width / 2;
            }
            touchFlick(showDragHandle,
                       xPos,
                       showDragHandle.height / 2,
                       xPos,
                       showDragHandle.height / 2 + (showDragHandle.autoCompleteDragThreshold * 1.1));
            tryCompare(panel.applicationMenus, "fullyOpened", true);
        }

        function test_drag_indicator_item_down_shows_menu_data() {
            return [
                { tag: "pinned", fullscreen: false, call: null, y: 0 },
                { tag: "fullscreen", fullscreen: true, call: null, y: -panel.minimizedPanelHeight },
                { tag: "pinned-callActive", fullscreen: false, call: phoneCall, y: 0},
                { tag: "fullscreen-callActive", fullscreen: true, call: phoneCall, y: -panel.minimizedPanelHeight }
            ];
        }

        // Dragging from a indicator item in the panel will gradually expose the
        // indicators, first by running the hint animation, then after dragging down will
        // expose more of the panel, binding it to the selected indicator and opening it's menu.
        // Tested from first Y pixel to check for swipe from offscreen.
        function test_drag_indicator_item_down_shows_menu(data) {
            skip("Unstable test; panel expansion refactor may be required");

            panel.fullscreenMode = data.fullscreen;
            callManager.foregroundCall = data.call;

            var panelRow = findChild(panel.indicators, "panelItemRow");
            verify(panelRow !== null);

            var menuContent = findChild(panel.indicators, "menuContent");
            verify(menuContent !== null);

            var panelArea = findChild(panel, "panelArea");
            verify(panelArea !== null);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompareFunction(function() { return panelArea.y }, data.y);

            for (var i = 0; i < root.originalModelData.length; i++) {
                waitForAllAnimationToComplete("initial");

                var indicatorItem = get_indicator_item(i);

                var startXPosition = panel.mapFromItem(indicatorItem, indicatorItem.width / 2, 0).x;

                touchFlick(panel,
                           startXPosition, 0,
                           startXPosition, panel.height,
                           true /* beginTouch */, false /* endTouch */, 1, 15);

                // Indicators height should follow the drag, and therefore increase accordingly.
                // They should be at least half-way through the screen
                tryCompareFunction(
                    function() {return panel.indicators.height >= panel.height * 0.5},
                    true);

                touchRelease(panel, startXPosition, panel.height);

                tryCompare(panelRow, "currentItemIndex", i, undefined, "Indicator item should be activated at position " + i);
                compare(menuContent.currentMenuIndex, i, "Menu conetent should be activated for item at position " + i);

                // init for next indicatorItem
                panel.indicators.hide();
            }
        }

        function test_drag_panel_handle_up_hides_menu_data() {
            return [
                { tag: "indicators-pinned", section: panel.indicators, fullscreen: false, call: null },
                { tag: "indicators-fullscreen", section: panel.indicators, fullscreen: true, call: null },
                { tag: "indicators-pinned-callActive", section: panel.indicators, fullscreen: false, call: phoneCall },
                { tag: "indicators-fullscreen-callActive", section: panel.indicators, fullscreen: true, call: phoneCall },
                { tag: "appMenus-pinned", section: panel.applicationMenus, fullscreen: false, call: null },
                { tag: "appMenus-fullscreen", section: panel.applicationMenus, fullscreen: true, call: null },
                { tag: "appMenus-pinned-callActive", section: panel.applicationMenus, fullscreen: false, call: phoneCall },
                { tag: "appMenus-fullscreen-callActive", section: panel.applicationMenus, fullscreen: true, call: phoneCall }
            ];
        }

        // Dragging the shown indicators up from bottom of panel will hide the indicators
        // Tested from last Y pixel to check for swipe from offscreen.
        function test_drag_panel_handle_up_hides_menu(data) {
            panel.fullscreenMode = data.fullscreen;
            callManager.foregroundCall = data.call;

            var panelRow = findChild(data.section, "panelItemRow");
            verify(panelRow !== null);

            var panelArea = findChild(panel, "panelArea");
            verify(panelArea !== null);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompareFunction(function() { return panelArea.y }, data.fullscreen ? -panel.minimizedPanelHeight : 0);

            data.section.show();
            tryCompare(data.section.showAnimation, "running", false);
            tryCompare(data.section, "unitProgress", 1);

            touchFlick(data.section,
                       data.section.width / 2, panel.height,
                       data.section.width / 2, 0,
                       true /* beginTouch */, false /* endTouch */, units.gu(5), 15);

            // Indicators height should follow the drag, and therefore increase accordingly.
            // They should be at least half-way through the screen
            tryCompareFunction(
                function() {return data.section.height <= panel.height * 0.5},
                true);

            touchRelease(data.section, data.section.width / 2, 0);

            tryCompare(data.section.hideAnimation, "running", true);
            tryCompare(data.section.hideAnimation, "running", false);
            tryCompare(data.section, "state", "initial");
        }

        function test_hint_data() {
            return [
                { tag: "indicators-normal", section: panel.indicators, fullscreen: false, call: null, hintExpected: true},
                { tag: "indicators-fullscreen", section: panel.indicators, fullscreen: true, call: null, hintExpected: false},
                { tag: "indicators-callActive", section: panel.indicators, fullscreen: false, call: phoneCall, hintExpected: false},
                { tag: "appMenus-normal", section: panel.applicationMenus, fullscreen: false, call: null, hintExpected: true},
                { tag: "appMenus-fullscreen", section: panel.applicationMenus, fullscreen: true, call: null, hintExpected: false},
                { tag: "appMenus-callActive", section: panel.applicationMenus, fullscreen: false, call: phoneCall, hintExpected: false},
            ];
        }

        function test_hint(data) {
            PanelState.title = "Fake Title"
            panel.fullscreenMode = data.fullscreen;
            callManager.foregroundCall = data.call;

            if (data.fullscreen) {
                // Wait for the indicators to get into position.
                // (switches between normal and fullscreen modes are animated)
                var panelArea = findChild(panel, "panelArea");
                tryCompare(panelArea, "y", -panel.minimizedPanelHeight);
            }

            var mappedPosition = root.mapFromItem(data.section,
                                                  data.section.barWidth / 2, data.section.minimizedPanelHeight / 2);

            touchPress(panel, mappedPosition.x, panel.minimizedPanelHeight / 2);

            var showDragHandle = findChild(data.section, "showDragHandle")
            var hintingAnimation = findInvisibleChild(showDragHandle, "hintingAnimation");
            verify(hintingAnimation);

            compare(hintingAnimation.running, data.hintExpected)
            tryCompare(hintingAnimation, "running", false); // wait till animation completes

            // no hint animation when fullscreen
            compare(data.section.partiallyOpened, data.hintExpected, "Indicator should be partialy opened");
            compare(data.section.fullyOpened, false, "Indicator should not be fully opened");

            touchRelease(panel, mappedPosition.x, panel.minimizedPanelHeight / 2);
        }

        function test_drag_applicationMenu_down_shows_menu_data() {
            return [
                { tag: "normal", fullscreen: false, call: null, hintExpected: true},
                { tag: "fullscreen", fullscreen: true, call: null, hintExpected: false},
                { tag: "callActive", fullscreen: false, call: phoneCall, hintExpected: false}
            ];
        }

        // Dragging the application menu will gradually expose the
        // menus, first by running the hint animation, then after dragging down will
        // expose more of the panel. Releasing the touch will complete the show.
        function test_drag_applicationMenu_down_shows_menu(data) {
            PanelState.title = "Fake Title";
            panel.fullscreenMode = data.fullscreen;
            callManager.foregroundCall = data.call;

            var panelRow = findChild(panel.indicators, "panelItemRow");
            verify(panelRow !== null);

            var menuContent = findChild(panel.indicators, "menuContent");
            verify(menuContent !== null);

            var panelArea = findChild(panel, "panelArea");
            verify(panelArea !== null);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            tryCompareFunction(function() { return panelArea.y }, data.fullscreen ? -panel.minimizedPanelHeight : 0);

            touchFlick(panel,
                       units.gu(1), 0,
                       units.gu(1), panel.height,
                       true /* beginTouch */, false /* endTouch */, units.gu(5), 15);

            // Indicators height should follow the drag, and therefore increase accordingly.
            // They should be at least half-way through the screen
            tryCompareFunction(
                function() {return panel.applicationMenus.height >= panel.height * 0.5},
                true);

            touchRelease(panel, units.gu(1), panel.height);

            tryCompare(panel.applicationMenus, "fullyOpened", true)
        }

        /* Checks that no input reaches items behind the indicator bar.
           Ie., the indicator bar should eat all input events that hit it.
         */
        function test_indicatorBarEatsAllEvents() {
            // Perform several taps throughout the length of the indicator bar to ensure
            // that it doesn't have a "weak spot" from where taps pass through.
            var numTaps = 5;
            var stepLength = (panel.width / (numTaps + 1));
            var tapY = panel.minimizedPanelHeight / 2;
            for (var i = 1; i <= numTaps; ++i) {
                tap(panel, stepLength * i, tapY);
                tryCompare(panel.indicators, "fullyClosed", true);
            }
        }

        function test_darkenedAreaEatsAllIndicatorEvents() {

            // The center of the area not covered by the indicators menu
            // Ie, the visible darkened area behind the menu
            var touchPosX = (panel.width - panel.indicators.width) / 2
            var touchPosY = panel.minimizedPanelHeight +
                    ((panel.height - panel.minimizedPanelHeight) / 2)

            // input goes through while the indicators menu is closed
            tryCompare(panel.indicators, "fullyClosed", true);
            compare(backgroundPressedSpy.count, 0);
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);

            pullDownIndicatorsMenu();

            // Darkened area eats input when the indicators menu is fully opened
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);
            backgroundPressedSpy.clear();

            // And should continue to eat inpunt until the indicators menu is fully closed
            wait(10);
            while (!panel.indicators.fullyClosed) {
                tap(panel, touchPosX, touchPosY);

                // it could have got fully closed during the tap
                // so we have to double check here
                if (!panel.indicators.fullyClosed) {
                    compare(backgroundPressedSpy.count, 0);
                }

                // let the animation go a bit further
                wait(50);
            }

            // Now that's fully closed, input should go through again
            backgroundPressedSpy.clear();
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);
        }

        function test_darkenedAreaEatsAllApplicationMenuEvents() {
            PanelState.title = "Fake Title"

            // The center of the area not covered by the indicators menu
            // Ie, the visible darkened area behind the menu
            var touchPosX = panel.applicationMenus.width + (panel.width - panel.applicationMenus.width) / 2
            var touchPosY = panel.minimizedPanelHeight +
                    ((panel.height - panel.minimizedPanelHeight) / 2)

            // input goes through while the indicators menu is closed
            tryCompare(panel.applicationMenus, "fullyClosed", true);
            compare(backgroundPressedSpy.count, 0);
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);

            pullDownApplicationsMenu();

            // Darkened area eats input when the indicators menu is fully opened
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);
            backgroundPressedSpy.clear();

            // And should continue to eat inpunt until the indicators menu is fully closed
            wait(10);
            while (!panel.applicationMenus.fullyClosed) {
                tap(panel, touchPosX, touchPosY);

                // it could have got fully closed during the tap
                // so we have to double check here
                if (!panel.applicationMenus.fullyClosed) {
                    compare(backgroundPressedSpy.count, 0);
                }

                // let the animation go a bit further
                wait(50);
            }

            // Now that's fully closed, input should go through again
            backgroundPressedSpy.clear();
            tap(panel, touchPosX, touchPosY);
            compare(backgroundPressedSpy.count, 2);
        }


        /*
          Regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1439318
          When the panel is in fullscreen mode and the user taps near the top edge,
          the panel should take no action and the tap should reach the item behind the
          panel.
         */
        function test_tapNearTopEdgeWithPanelInFullscreenMode() {
            var panelArea = findChild(panel, "panelArea");
            verify(panelArea);

            panel.fullscreenMode = true;
            // wait until if finishes hiding itself
            tryCompare(panelArea, "y", -panel.minimizedPanelHeight);

            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);

            // tap near the very top of the screen
            tap(itemArea, itemArea.width / 2, 2);

            // the tap should have reached the item behind the panel
            compare(backgroundPressedSpy.count, 2);

            // give it a couple of event loop iterations for any animations etc to kick in
            wait(50);

            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);
        }

        function test_tapToReturnCallDoesntExpandIndicators() {
            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);

            callManager.foregroundCall = phoneCall;

            var dashApp = ApplicationManager.startApplication("unity8-dash");
            tryCompare(dashApp.surfaceList, "count", 1);
            dashApp.surfaceList.get(0).activate();
            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");

            mouseClick(panel.indicators,
                       panel.indicators.width / 2,
                       panel.minimizedPanelHeight / 2);

            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);

            // clean up
            ApplicationManager.stopApplication("unity8-dash");
        }

        function test_openAndClosePanelWithMouseClicks() {
            compare(panel.indicators.shown, false);
            verify(panel.indicators.fullyClosed);

            mouseClick(panel.indicators,
                    panel.indicators.width / 2,
                    panel.minimizedPanelHeight / 2);

            compare(panel.indicators.shown, true);
            tryCompare(panel.indicators, "fullyOpened", true);

            var handle = findChild(panel.indicators, "handle");
            verify(handle);

            mouseClick(handle);

            compare(panel.indicators.shown, false);
            tryCompare(panel.indicators, "fullyClosed", true);
        }

        // https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1611959
        function test_windowControlButtonsFittsLaw() {
            panel.mode = "windowed";
            var windowControlArea = findChild(panel, "windowControlArea");
            verify(windowControlArea, "Window control area should have been created in windowed mode")

            PanelState.decorationsVisible = true;
            // click in very topleft corner and verify the close button got clicked too
            mouseMove(panel, 0, 0);
            mouseClick(panel, 0, 0, undefined /*button*/, undefined /*modifiers*/, 100 /*short delay*/);
            compare(windowControlButtonsSpy.count, 1);
        }

        function test_hidingKeyboardIndicator_data() {
            return [
                { tag: "No keyboard, no keymap", keyboard: false, keymaps: [], hidden: true },
                { tag: "No keyboard, one keymap", keyboard: false, keymaps: ["us"], hidden: true },
                { tag: "No keyboard, 2 keymaps", keyboard: false, keymaps: ["us", "cs"], hidden: true },
                { tag: "Keyboard, no keymap", keyboard: true, keymaps: [], hidden: false },
                { tag: "Keyboard, one keymap", keyboard: true, keymaps: ["us"], hidden: false },
                { tag: "Keyboard, 2 keymaps", keyboard: true, keymaps: ["us", "cs"], hidden: false }
            ];
        }

        function test_hidingKeyboardIndicator(data) {
            var item = findChild(panel, "indicator-keyboard-panelItem");
            AccountsService.keymaps = data.keymaps;
            panel.hasKeyboard = data.keyboard;
            if (data.keyboard) {
                MockInputDeviceBackend.addMockDevice("/indicator_kbd0", InputInfo.Keyboard);
            } else {
                MockInputDeviceBackend.removeDevice("/indicator_kbd0");
            }

            compare(item.hidden, data.hidden);
        }

        function test_visibleIndicators_data() {
            return [
                { visible: [true, false, true, false, true, true, false, true] },
                { visible: [true, false, false, false, false, false, true, false] }
            ];
        }

        function test_visibleIndicators(data) {
            panel.hasKeyboard = true;
            for (var i = 0; i < data.visible.length; i++) {
                var visible = data.visible[i];
                root.setIndicatorVisible(i, visible);

                var dataItem = findChild(panel, root.originalModelData[i]["identifier"] + "-panelItem");
                tryCompare(dataItem, "opacity", visible ? 1.0 : 0.0);
                tryCompareFunction(function() { return dataItem.width > 0.0; }, visible);
            }

            panel.indicators.show();
            tryCompare(panel.indicators.showAnimation, "running", false);
            tryCompare(panel.indicators, "unitProgress", 1);

            for (var i = 0; i < data.visible.length; i++) {
                root.setIndicatorVisible(i, data.visible[i]);

                var dataItem = findChild(panel, root.originalModelData[i]["identifier"] + "-panelItem");
                tryCompareFunction(function() { return dataItem.opacity > 0.0; }, true);
                tryCompareFunction(function() { return dataItem.width > 0.0; }, true);
            }
        }

        function test_stagedApplicationMenuBarShowOnMouseHover() {
            PanelState.title = "Fake Title";
            panel.mode = "staged";
            mouseEmulation.checked = false;

            var appTitle = findChild(panel, "panelTitle"); verify(appTitle);
            var appMenuRow = findChild(panel.applicationMenus, "panelRow"); verify(appMenuRow);
            var menuBarLoader = findChild(panel, "menuBarLoader"); verify(menuBarLoader);

            tryCompare(appTitle, "visible", true, undefined, "App title should be visible");
            tryCompare(menuBarLoader, "visible", false, undefined, "App menu bar should not be visible");

            mouseMove(panel, panel.width/2, panel.panelHeight);

            var appMenuBar = findChild(panel, "menuBar"); verify(appMenuBar);
            tryCompare(appTitle, "visible", false, undefined, "App title should not be visible on mouse hover");
            tryCompare(appMenuBar, "visible", true, undefined, "App menu bar should be visible on mouse hover");
        }

        function test_keyboardNavigation_data() {
            return [
                {tag: "tab to start", doTab: false},
                {tag: "no tab to start", doTab: true}
            ]
        }

        function test_keyboardNavigation(data) {
            var indicatorsBar = findChild(panel.indicators, "indicatorsBar");

            pullDownIndicatorsMenu();

            indicatorsBar.setCurrentItemIndex(0);

            if (data.doTab) {
                keyClick(Qt.Key_Tab);
            }

            keyClick(Qt.Key_Right);
            tryCompare(indicatorsBar, "currentItemIndex", 1);

            keyClick(Qt.Key_Right);
            tryCompare(indicatorsBar, "currentItemIndex", 2);

            keyClick(Qt.Key_Left);
            tryCompare(indicatorsBar, "currentItemIndex", 1);

            keyClick(Qt.Key_Left);
            tryCompare(indicatorsBar, "currentItemIndex", 0);

            keyClick(Qt.Key_Escape);
            tryCompare(panel.indicators, "fullyClosed", true);
        }

        function test_aboutToShowMenu() {
            waitForRendering(panel);

            aboutToShowCalledSpy.target = panel.applicationMenus.model
            aboutToShowCalledSpy.clear();

            var indicatorsBar = findChild(panel.applicationMenus, "indicatorsBar");

            PanelState.title = "Fake Title"
            pullDownApplicationsMenu(0 /*xPos*/);
            compare(aboutToShowCalledSpy.count, 1);

            keyClick(Qt.Key_Right);
            tryCompare(indicatorsBar, "currentItemIndex", 1);
            compare(aboutToShowCalledSpy.count, 2);

            compare(aboutToShowCalledSpy.signalArguments[0][0], 0);
            compare(aboutToShowCalledSpy.signalArguments[1][0], 1);

            keyClick(Qt.Key_Tab);
            keyClick(Qt.Key_Tab);

            aboutToShowCalledSpy.target = panel.applicationMenus.model.submenu(1);
            aboutToShowCalledSpy.clear();

            keyClick(Qt.Key_Enter);
            compare(aboutToShowCalledSpy.count, 1);
        }

        function test_disabledTopLevel() {
            var modelData = appMenuData.generateTestData(3,3,0,0,"menu");
            modelData[1].rowData.sensitive = false;
            panel.applicationMenus.model.modelData = modelData;

            waitForRendering(panel);

            aboutToShowCalledSpy.target = panel.applicationMenus.model
            aboutToShowCalledSpy.clear();

            var indicatorsBar = findChild(panel.applicationMenus, "indicatorsBar");

            PanelState.title = "Fake Title"
            pullDownApplicationsMenu(0 /*xPos*/);

            tryCompare(indicatorsBar, "currentItemIndex", 0);

            keyClick(Qt.Key_Right);
            tryCompare(indicatorsBar, "currentItemIndex", 2);

            keyClick(Qt.Key_Left);
            tryCompare(indicatorsBar, "currentItemIndex", 0);
        }
    }
}
