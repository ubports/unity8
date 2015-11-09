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
import Ubuntu.Components 1.3
import QtTest 1.0
import "../../../../qml/Dash/ScopeSettings"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)

    property var settingData: {
        "type": "",
        "displayName" : "Mock setting",
        "value": "1",
        "properties": { "values" : [ "first", "second", "third" ] }
    }

    ScopeSettingsWidgetFactory {
        id: scopeSettingsWidgetFactory
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "ScopeSettingWidgetFactory"
        when: windowShown

        function test_mapping_data() {
            return [
                { tag: "Boolean", type: "boolean", source: "ScopeSettingBoolean.qml" },
                { tag: "List", type: "list", source: "ScopeSettingList.qml" },
                { tag: "Number", type: "number", source: "ScopeSettingNumber.qml" },
                { tag: "String", type: "string", source: "ScopeSettingString.qml" }
            ];
        }

        function test_mapping(data) {
            var newSettingData = settingData;
            newSettingData.type = data.type;
            scopeSettingsWidgetFactory.widgetData = newSettingData;

            verify((String(scopeSettingsWidgetFactory.source)).indexOf(data.source) != -1);
        }
    }
}
