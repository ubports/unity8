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

import QtQuick 2.4
import QtTest 1.0
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3


Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    property var actionDataOneAction: {
        "actions": [{"label": "Some Label", "id": "someid"}]
    }

    property var actionDataTwoActions: {
        "actions": [{"label": "Some Label A", "id": "someid1"},
                    {"label": "Some Label B", "id": "someid2"}
        ]
    }

    property var actionDataFiveActions: {
        "actions": [{"label": "Some Label C", "id": "someid3"},
                    {"label": "Some Label D", "id": "someid4"},
                    {"label": "Some Label E", "id": "someid5"},
                    {"label": "Some Label F", "id": "someid6"},
                    {"label": "Some Label G", "id": "someid7"}
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
            onTriggered: console.log("triggered", widgetId, actionId);
            width: units.gu(50)

            Rectangle {
                anchors.fill: parent
                color: "red"
                opacity: 0.1
            }
        }

        PreviewActions {
            id: buttonAndCombo
            widgetId: "buttonAndCombo"
            widgetData: actionDataFiveActions
            onTriggered: console.log("triggered", widgetId, actionId);
            width: units.gu(40)

            Rectangle {
                anchors.fill: parent
                color: "red"
                opacity: 0.1
            }
        }

        PreviewActions {
            id: twoActions
            widgetId: "2buttons"
            widgetData: actionDataTwoActions
            onTriggered: console.log("triggered", widgetId, actionId);
            width: units.gu(60)
        }
    }

    UT.UnityTestCase {
        name: "PreviewActionTest"
        when: windowShown

        function cleanup()
        {
            spy.clear();
        }

        function checkButtonPressSignal(target, id)
        {
            var button = findChild(root, "button" + id);
            verify(button != null);
            spy.target = target;
            mouseClick(button);
            compare(spy.count, 1);
            compare(spy.signalArguments[0][0], target.widgetId);
            compare(spy.signalArguments[0][1], id);
        }

        function test_checkButtons_data() {
            return [
                {tag: "oneActionButton", target: oneAction, id: "someid" },
                {tag: "twobuttonsButton0", target: twoActions, id: "someid1" },
                {tag: "twobuttonsButton1", target: twoActions, id: "someid2" },
                {tag: "buttonAndComboButton0", target: buttonAndCombo, id: "someid3" }
            ]
        }

        function test_checkButtons(data) {
            checkButtonPressSignal(data.target, data.id, data.buttonNumber)
        }

        function test_comboButton_data() {
            return [
                {tag: "button1", id: "someid4" },
                {tag: "button2", id: "someid5" },
                {tag: "button3", id: "someid6" },
                {tag: "button4", id: "someid7" }
            ]
        }

        function test_comboButton(data) {
            var button = findChild(root, "moreLessButton");
            var buttonColumn = findChild(root, "buttonColumn");
            verify(button != null);
            var twoActionsY = twoActions.y
            mouseClick(button);
            tryCompareFunction(function () { return twoActions.y <= twoActionsY; }, false);
            tryCompare(buttonColumn, "height", buttonColumn.implicitHeight);
            checkButtonPressSignal(buttonAndCombo, data.id, data.buttonNumber);
            mouseClick(button);
            tryCompare(twoActions, "y", twoActionsY);
        }
    }
}
