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

import QtQuick 2.4
import QtTest 1.0
import ".."
import "../../../qml/Greeter"
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import LightDM.FullLightDM 0.1 as LightDM

Item {
    property variant infographicModel: LightDM.Infographic

    width: units.gu(120)
    height: units.gu(120)

    Loader {
        id: loader

        active: false
        anchors.fill: parent

        property bool componentDestroyed: true
        sourceComponent: Component {
            Infographics {
                id: infographic
                width: loader.width
                height: loader.height
                model: infographicModel

                Component.onDestruction: {
                    loader.componentDestroyed = true
                }
            }
        }
    }

    UT.UnityTestCase {
        name: "Infographics"
        when: windowShown

        property var dataCircle
        property var dots
        property var label
        property var presentCircles
        property var pastCircles
        property var infographic

        function reloadInfographic() {
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            tryCompare(loader, "componentDestroyed", true);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
            loader.componentDestroyed = false
            infographic = loader.item
        }

        function reloadModel() {
           infographicModel.reset()
        }

        function init() {
            reloadModel()
            reloadInfographic()
            dataCircle = findChild(infographic, "dataCircle")
            dots =  findChild(infographic, "dots")
            label =  findChild(infographic, "label")
            presentCircles =  findChild(infographic, "presentCircles")
            pastCircles = findChild(infographic, "pastCircles")
        }

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

        function test_update_userdata_when_new_day_data()
        {
            return [
               { tag: "Same day", 	   currentDayOffset: 0, label: "<b>19</b> minutes talk time" },
               { tag: "Different day", currentDayOffset: 1, label: "<b>33</b> messages today" },
            ]
        }

        function test_update_userdata_when_new_day(data)
        {
            //Given
            var today = new Date().getDay()
            infographicModel.username = "single"
            infographic.currentWeekDay = (today - data.currentDayOffset)

            //When
            infographic.handleTimerTrigger()

            //Then
            tryCompare(infographic, "currentWeekDay", today)
            tryCompare(label, "text", data.label)
        }
    }

    Dot { id: dot }
    ObjectPositioner { id: objectPositioner }
}
