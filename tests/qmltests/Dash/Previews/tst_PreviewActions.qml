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

    Column {
        spacing: units.gu(1)

        PreviewActions {
            widgetId: "button"
            widgetData: actionDataOneAction
            onTriggered: console.log("triggered", widgetId, actionId, data);
        }

        PreviewActions {
            widgetId: "buttonAndCombo"
            widgetData: actionDataFiveActions
            onTriggered: console.log("triggered", widgetId, actionId, data);
        }

        PreviewActions {
            widgetId: "2buttons"
            widgetData: actionDataTwoActions
            onTriggered: console.log("triggered", widgetId, actionId, data);
        }
    }

    UT.UnityTestCase {
        name: "PreviewActionTest"
        when: windowShown

        function test_changeEmptyModel() {
            wait(5000);
//             imageGallery.widgetData = sourcesModel0;
//             var placeholderScreenshot = findChild(imageGallery, "placeholderScreenshot");
//             compare(placeholderScreenshot.visible, true);
        }
    }
}
