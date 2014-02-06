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

import QtQuick 2.0
import QtTest 1.0
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import Ubuntu.Components 0.1


Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    property var actionDataOneAction: {
        "actions": [{"label": "Some Label", "icon": "../graphics/play_button.png", "id": "someid"}]
    }

    property var actionDataTwoActions: {
        "actions": [{"label": "Some Label A", "icon": "../graphics/icon_clear.png", "id": "someid1"},
                    {"label": "Some Label B", "icon": "../graphics/play_button.png", "id": "someid2"}
        ]
    }

    property var actionDataFiveActions: {
        "actions": [{"label": "Some Label C", "icon": "../graphics/play_button.png", "id": "someid3"},
                    {"label": "Some Label D", "icon": "../graphics/icon_clear.png", "id": "someid4"},
                    {"label": "Some Label E", "icon": "../graphics/play_button.png", "id": "someid5"},
                    {"label": "Some Label F", "icon": "../graphics/icon_clear.png", "id": "someid6"},
                    {"label": "Some Label G", "icon": "../graphics/play_button.png", "id": "someid7"}
        ]
    }

    SignalSpy {
        id: spy
        signalName: "triggered"
    }

    Column {
        spacing: units.gu(1)

        PreviewActions {
            id: oneAction
            widgetId: "button"
            widgetData: actionDataOneAction
            onTriggered: console.log("triggered", widgetId, actionId, data);
        }

        PreviewActions {
            id: buttonAndCombo
            widgetId: "buttonAndCombo"
            widgetData: actionDataFiveActions
            onTriggered: console.log("triggered", widgetId, actionId, data);
        }

        PreviewActions {
            id: twoActions
            widgetId: "2buttons"
            widgetData: actionDataTwoActions
            onTriggered: console.log("triggered", widgetId, actionId, data);
        }
    }

    UT.UnityTestCase {
        name: "PreviewActionTest"
        when: windowShown

        function checkButtonPressSignal(target, id, buttonNumber)
        {
            var button = findChild(root, "button" + id);
            verify(button != null);
            spy.target = target;
            spy.clear();
            mouseClick(button, button.width / 2, button.height / 2);
            compare(spy.count, 1);
            compare(spy.signalArguments[0][0], target.widgetId);
            compare(spy.signalArguments[0][1], id);
            compare(spy.signalArguments[0][2], target.widgetData["actions"][buttonNumber]);
        }

        function test_checkButtons_data() {
            return [
                {tag: "oneActionButton", target: oneAction, id: "someid", buttonNumber: 0 },
                {tag: "twobuttonsButton0", target: twoActions, id: "someid1", buttonNumber: 0 },
                {tag: "twobuttonsButton1", target: twoActions, id: "someid2", buttonNumber: 1 },
                {tag: "buttonAndComboButton0", target: buttonAndCombo, id: "someid3", buttonNumber: 0 }
            ]
        }

        function test_checkButtons(data) {
            checkButtonPressSignal(data.target, data.id, data.buttonNumber)
        }

        function test_comboButton_data() {
            return [
                {tag: "button1", id: "someid4", buttonNumber: 1 },
                {tag: "button2", id: "someid5", buttonNumber: 2 },
                {tag: "button3", id: "someid6", buttonNumber: 3 },
                {tag: "button4", id: "someid7", buttonNumber: 4 }
            ]
        }

        function test_comboButton(data) {
            var button = findChild(root, "moreLessButton");
            verify(button != null);
            var twoActionsY = twoActions.y
            mouseClick(button, button.width / 2, button.height / 2);
            tryCompareFunction(function () { return twoActions.y <= twoActionsY; }, false);
            checkButtonPressSignal(buttonAndCombo, data.id, data.buttonNumber);
            mouseClick(button, button.width / 2, button.height / 2);
            tryCompare(twoActions, "y", twoActionsY);
        }
    }
}
