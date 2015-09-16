    /*
 * Copyright 2013 Canonical Ltd.
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
import ".."
import "../../../qml/Greeter"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import IntegratedLightDM 0.1 as LightDM

Item {
    Binding {
        target: LightDM.Greeter
        property: "mockMode"
        value: "full"
    }
    Binding {
        target: LightDM.Users
        property: "mockMode"
        value: "full"
    }
    property variant infographicModel: LightDM.Infographic

    width: units.gu(120)
    height: units.gu(120)

    UT.UnityTestCase {
        name: "Infographics"
        when: windowShown

        property var dataCircle: findChild(infographic, "dataCircle")
        property var dots: findChild(infographic, "dots")
        property var label: findChild(infographic, "label")
        property var presentCircles: findChild(infographic, "presentCircles")
        property var pastCircles: findChild(infographic, "pastCircles")

        function test_dot_states_data() {
            return [
                { tag: "pointer",  state: "pointer",  result: Image.Ready },
                { tag: "filled",   state: "filled",   result: Image.Ready },
                { tag: "unfilled", state: "unfilled", result: Image.Ready },
                { tag: "invalid",  state: "foobar",   result: Image.Null },
            ]
        }

        function test_dot_states(data) {
            dot.state = data.state
            tryCompare(dot, "status", data.result)
        }

        function test_circle_position() {
            objectPositioner.radius = 50
            objectPositioner.halfSize = 25
            objectPositioner.posOffset = 0.0
            objectPositioner.slice = (2 * Math.PI / 20) * 0

            compare(objectPositioner.x, (objectPositioner.radius - objectPositioner.halfSize * objectPositioner.posOffset) *
                    Math.sin(objectPositioner.slice) + objectPositioner.radius - objectPositioner.halfSize, "Circle position")
        }

        function test_set_username_data() {
            return [
                { username: "has-password", label: "<b>19</b> minutes talk time", visible: true },
                { username: "two-factor", label: "", visible: true },
                { username: "", label: "", visible: false },
            ]
        }

        function test_set_username(data) {
            infographicModel.username = data.username
            tryCompare(label, "text", data.label)
            compare(infographic.visible, data.visible);
        }
    }

    Infographics {
        id: infographic

        anchors.fill: parent
        model: infographicModel
    }

    Dot { id: dot }
    ObjectPositioner { id: objectPositioner }
}
