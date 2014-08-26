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
import Ubuntu.Components 1.1
import QtTest 1.0
import "../../../../qml/Dash/ScopeSettings"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)

    property var settingData: {
        "displayName" : "Mock list setting",
        "properties": { "values" : [ "first", "second", "third" ] }
    }

    ScopeSettingList {
        id: scopeSetting
        widgetData: settingData
        width: parent.width
    }

    SignalSpy {
        id: spy
        target: scopeSetting
        signalName: "updated"
    }

    UT.UnityTestCase {
        id: testCase
        name: "ScopeSettingList"
        when: windowShown

        property var control: findChild(scopeSetting, "control")

        function cleanup() {
            control.selectedIndex = 0;
            spy.clear();
        }

        function test_updated_data() {
            return [
                { tag: "current", index: 0, updated: false },
                { tag: "second", index: 1, updated: true },
                { tag: "third", index: 2, updated: true }
            ]
        }

        function test_updated(data) {
            control.selectedIndex = data.index;
            if (data.updated) {
                spy.wait();
                compare(spy.signalArguments[0][0], data.index);
            } else {
                compare(spy.count, 0);
            }
        }
    }
}
