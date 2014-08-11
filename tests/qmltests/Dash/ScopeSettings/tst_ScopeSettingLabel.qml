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
import "../../../../qml/Dash/ScopeSettings"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)

    property var settingData: {
        "displayName" : "Fake label setting",
        "value": "fake label"
    }

    ScopeSettingLabel {
        id: scopeSettingLabel
        widgetData: settingData
        width: units.gu(40)

        Rectangle {
            anchors.fill: parent
            color: "red"
            opacity: 0.1
        }
    }

    SignalSpy {
        id: triggeredSpy
        target: scopeSettingSwitch
        signalName: "triggered"
    }

    UT.UnityTestCase {
        id: testCase
        name: "ScopeSettingLabelTest"
        when: windowShown

        function test_triggered() {
        }
    }
}
