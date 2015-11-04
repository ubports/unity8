/*
 * Copyright 2015 Canonical Ltd.
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

    property var actionDataActions: {
        "actions": [{"label": "10", "id": "someid", "icon": Qt.resolvedUrl("../artwork/avatar@12.png"), "temporaryIcon": Qt.resolvedUrl("../artwork/emblem.png")},
                    {"label": "12", "id": "someid2", "icon": Qt.resolvedUrl("../artwork/checkers.png"), "temporaryIcon": Qt.resolvedUrl("../artwork/background.png")},
                    {"label": "", "id": "someid3", "icon": Qt.resolvedUrl("../artwork/music-player-design.png")},
        ]
    }

    SignalSpy {
        id: spy
        signalName: "triggered"
    }

    PreviewIconActions {
        id: preview
        widgetId: "iconActions"
        widgetData: actionDataActions
        onTriggered: {
            if (timer.index !== -1) {
                if (!testcase.running) {
                    console.log("Processing other click, ignoring");
                }
                return;
            }

            for (var i in actionDataActions.actions) {
                if (actionId == actionDataActions.actions[i].id) {
                    timer.index = i;
                    break;
                }
            }

            timer.start();
            if (!testcase.running) {
                console.log("triggered", widgetId, actionId);
            }
        }
        width: parent.width
        clip: true
    }

    Timer {
        id: timer
        property int index: -1
        interval: 500
        onTriggered: {
            actionDataActions.actions[index].icon = Qt.resolvedUrl("../../UnityLogo.png");
            preview.widgetDataChanged();
            index = -1;
        }
    }

    UT.UnityTestCase {
        id: testcase
        name: "PreviewIconActionTest"
        when: windowShown

        function cleanup()
        {
            spy.clear();
        }

        function test_checkButtonWithTemporary_data() {
            return [
                {tag: "with temporary", temporaryIcon: "emblem", index: 0},
                {tag: "without temporary", temporaryIcon: undefined, index: 2},
            ];
        }

        function test_checkButtonWithTemporary(data) {
            spy.target = preview;

            var buttonId = actionDataActions.actions[data.index].id;
            var buttonIcon = actionDataActions.actions[data.index].icon;
            var buttonTemporaryIcon = actionDataActions.actions[data.index]["temporaryIcon"];
            var buttonLabel = actionDataActions.actions[data.index].label;

            var button = findChild(root, "button" + buttonId);
            var image = findChildsByType(button, "QQuickImage")[0];
            var label = findChildsByType(button, "UCLabel")[0];

            compare(image.source, buttonIcon);
            compare(label.text, buttonLabel);
            mouseClick(button);
            compare(spy.count, 1);
            compare(spy.signalArguments[0][1], buttonId);

            if (buttonTemporaryIcon) {
                compare(image.source, buttonTemporaryIcon);
            }

            tryCompareFunction(function() {
                var button = findChild(root, "button" + buttonId);
                var image = findChildsByType(button, "QQuickImage")[0];
                return image.source && image.source.toString().indexOf("UnityLogo") > -1;
            }, true);
        }
    }
}
