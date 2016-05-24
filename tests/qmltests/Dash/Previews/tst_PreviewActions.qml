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

    readonly property var actionDataOneAction: {
        "actions": [{"label": "Some Label", "id": "someid"}]
    }

    readonly property var actionDataTwoActions: {
        "actions": [{"label": "Some Label A", "id": "someid1"},
                    {"label": "Some Label B", "id": "someid2"}
        ]
    }

    readonly property var actionDataFiveActions: {
        "actions": [{"label": "Some Label C", "id": "someid3"},
                    {"label": "Some Label D", "id": "someid4"},
                    {"label": "Some Label E", "id": "someid5"},
                    {"label": "Some Label F", "id": "someid6"},
                    {"label": "Some Label G", "id": "someid7"}
        ]
    }

    property var actionModelActions: {
        "actions": [{"label": "Some Label H", "id": "someid8"},
                    {"label": "Some Label I", "id": "someid9"},
                    {"label": "Some Label J", "id": "someid10"},
                    {"label": "Some Label K", "id": "someid11"},
                    {"label": "Some Label L", "id": "someid12"}
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

        PreviewActions {
            id: changeModelActions
            width: units.gu(60)
        }

        PreviewActions {
            id: updateModelActions
            width: units.gu(60)
        }
    }

    UT.UnityTestCase {
        name: "PreviewActionTest"
        when: windowShown

        function checkButtonPressSignal(target, id)
        {
            var button = findChild(target, "button" + id);
            verify(button != null);
            spy.target = target;
            mouseClick(button);
            compare(spy.count, 1);
            compare(spy.signalArguments[0][0], target.widgetId);
            compare(spy.signalArguments[0][1], id);
            spy.clear();
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
            checkButtonPressSignal(data.target, data.id)
        }

        function test_comboButton_data() {
            return [
                {tag: "button1", id: "someid4" },
                {tag: "button2", id: "someid5" },
                {tag: "button3", id: "someid6" },
                {tag: "button4", id: "someid7" }
            ]
        }

        function pressMoreButton(buttonGroup)
        {
            var button = findChild(buttonGroup, "moreLessButton");
            var buttonColumn = findChild(buttonGroup, "buttonColumn");
            verify(button != null);
            mouseClick(button);
            tryCompare(buttonColumn, "height", buttonColumn.implicitHeight);
        }

        function test_comboButton(data) {
            var twoActionsY = twoActions.y
            pressMoreButton(buttonAndCombo);
            tryCompareFunction(function () { return twoActions.y <= twoActionsY; }, false);
            checkButtonPressSignal(buttonAndCombo, data.id);
            mouseClick(findChild(buttonAndCombo, "moreLessButton"));
            tryCompare(twoActions, "y", twoActionsY);
        }

        function test_modelChange() {
            changeModelActions.widgetData = actionDataOneAction;
            waitForRendering(changeModelActions);
            checkButtonPressSignal(changeModelActions, "someid");

            changeModelActions.widgetData = actionDataTwoActions;
            waitForRendering(changeModelActions);
            checkButtonPressSignal(changeModelActions, "someid1");
            checkButtonPressSignal(changeModelActions, "someid2");

            changeModelActions.widgetData = actionDataFiveActions;
            waitForRendering(changeModelActions);
            pressMoreButton(changeModelActions);
            checkButtonPressSignal(changeModelActions, "someid3");
            checkButtonPressSignal(changeModelActions, "someid4");
            checkButtonPressSignal(changeModelActions, "someid5");
            checkButtonPressSignal(changeModelActions, "someid6");
        }

        function test_modelUpdate() {
            updateModelActions.widgetData = actionModelActions;
            waitForRendering(updateModelActions);
            pressMoreButton(updateModelActions);
            checkButtonPressSignal(updateModelActions, "someid8");
            checkButtonPressSignal(updateModelActions, "someid9");
            checkButtonPressSignal(updateModelActions, "someid10");
            checkButtonPressSignal(updateModelActions, "someid11");
            checkButtonPressSignal(updateModelActions, "someid12");

            updateModelActions["actions"].pop();
            updateModelActions.actionsChanged();

            // Check that some12 is gone
            verify(!findChild(updateModelActions, "buttonsomeid12"));

            updateModelActions["actions"][3].id = "someidmoo";
            updateModelActions.actionsChanged();
            checkButtonPressSignal(updateModelActions, "someidmoo");

            verify(findChild(updateModelActions, "moreLessButton"));

            updateModelActions["actions"].pop();
            updateModelActions["actions"].pop();
            updateModelActions.actionsChanged();

            // Check there is no more/less button anymore
            verify(!findChild(updateModelActions, "moreLessButton"));

            updateModelActions["actions"][1].id = "someidbar";
            updateModelActions.actionsChanged();
            checkButtonPressSignal(updateModelActions, "someidbar");

            updateModelActions["actions"].pop();
            updateModelActions.actionsChanged();

            // Check the loader for the second button/combo is gone
            compare(findChild(updateModelActions, "loader").source, "");

            updateModelActions["actions"][0].id = "someidlolar";
            updateModelActions.actionsChanged();
            checkButtonPressSignal(updateModelActions, "someidlolar");
        }
    }
}
