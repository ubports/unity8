/*
 * Copyright 2013-2015 Canonical Ltd.
 * Copyright 2020 UBports Foundation
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
import Lomiri.SelfTest 0.1
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Application 0.1
import QMenuModel 0.1
import Lomiri.Telephony 0.1 as Telephony
import AccountsService 0.1
import Lomiri.InputInfo 0.1
import "../../../qml/Panel"
import "../../../qml/Components/PanelState"
import "../Stage"
import ".."

PanelUI {
    id: root
    width: units.gu(71)

    LomiriTestCase {
        name: "PanelSmallScreen"
        when: windowShown

        function init() {
            panel.mode = "staged";
            mouseEmulation.checked = true;
            panel.fullscreenMode = false;
            callManager.foregroundCall = null;

            PanelState.title = "Fake Window Title"
            PanelState.decorationsVisible = false;

            // Put the mouse somewhere neutral so it doesn't hover over things
            // and mess up the test
            mouseMove(root, 0, 0);

            // Wait for the indicators to get into position.
            // (switches between normal and fullscreen modes are animated)
            var panelArea = findChild(panel, "panelArea");
            tryCompare(panelArea, "y", 0);

            waitForRendering(panel);
        }

        function cleanup() {
            var messagingMenu = findChild(panel, "fake-indicator-messages-panelItem");
            // Make all indicators visible again
            for (var i = 0; i < originalModelData.length; i++) {
                root.setIndicatorVisible(i, true);
            }
            panel.hasKeyboard = false;
            panel.indicators.hide();
            panel.applicationMenus.hide();
            waitForAllAnimationToComplete("initial");
            tryCompare(panel.indicators, "fullyClosed", true);
            tryCompare(panel.applicationMenus, "fullyClosed", true);
            // Wait for indicators to fade in all the way
            tryCompare(messagingMenu, "opacity", 1);
        }

        function get_indicator_item(index) {
            var indicatorItem = findChild(panel, root.originalModelData[index]["identifier"]+"-panelItem");
            verify(indicatorItem);

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
                verify(itemState);

                waitUntilTransitionsEnd(itemState);
            }

            tryCompare(panel.applicationMenus.hideAnimation, "running", false);
            tryCompare(panel.applicationMenus, "state", state);
        }


        /*
            Ensures that things the Shell assumes to be true at a phone size
            are, indeed, true:

            * The PanelTitle is empty
            * The "down" icon is shown
            * Pulling down from just left of the Indicators pulls the
              Application Menus
        */
        function test_assumptions() {
            var rowTitle = findChild(panel, "panelTitle");
            var touchMenuIcon = findChild(panel, "touchMenuIcon");
            var indicatorDragHandle = findChild(panel.indicators, "showDragHandle");
            var showDragHandle = findChild(panel.applicationMenus, "showDragHandle");

            compare(rowTitle.text, "");
            compare(touchMenuIcon.visible, true);

            touchFlick(indicatorDragHandle,
                       -1,
                       showDragHandle.height / 2,
                       -1,
                       showDragHandle.height / 2 + (showDragHandle.autoCompleteDragThreshold * 1.1));
            tryCompare(panel.applicationMenus, "fullyOpened", true);
        }
    }
}
