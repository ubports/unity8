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
import "../../../Panel/Menus"
import "../../../Components"
import Unity.Test 0.1 as UT
import IndicatorsClient 0.1

Rectangle {
    id: shell
    width: units.gu(40)
    height: units.gu(80)
    color: "black"

    Overview {
        id: overview
        anchors.fill: parent
        indicatorsModel: mockModel
        shown: true
    }

    Item {
        id: volumeControl
        property int volume
        function volumeUp() {
            volume = Math.min(100, volume + 10);
        }
        function volumeDown() {
            volume = Math.max(0, volume - 10);
        }
    }

    ListModel {
        id: mockModel
        ListElement {title: "fake1"; iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon1.qml"; indicatorProperties: ""}
        ListElement {title: "fake2"; iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon2.qml"; indicatorProperties: ""}
        ListElement {title: "fake3"; iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon3.qml"; indicatorProperties: ""}
    }

    ListModel {
        id: mockModel2
    }

    SignalSpy {
        id: clickSpy
        target: overview
        signalName: "menuSelected"
    }

    UT.UnityTestCase {
        name: "Overview"
        when: windowShown

        function initTestCase() {
            // Spin the event loop once because the UI builds up delayed
            wait(0);
        }

        function test_menuSelected() {
            overview.indicatorsModel = mockModel;

            for (var i = 0; i < mockModel.count; ++i) {
                var button = findChild(overview, "overviewGridButton" + i);
                clickSpy.clear();
                mouseClick(button, button.width / 2, button.height / 2);
                compare(clickSpy.count, 1, "Clicking on grid didn't work");
                compare(clickSpy.signalArguments[0][0], i, "Clicking the grid returned a wrong index");
            }
        }

        function test_dynamic_addition() {
            var overviewGrid = findChild(overview, "overviewGrid");

            for(var i = 0; i < mockModel.count; ++i) {
                mockModel2.append(mockModel.get(i));
            }
            overview.indicatorsModel = mockModel2;
            overviewGrid.forceLayout();
            waitForRendering(overviewGrid);

            var button = findChild(overview, "overviewGridButton2");
            verify(button !== undefined, "button2 wasn't found");
            button = findChild(overview, "overviewGridButton3");
            compare(button, undefined, "There should only be 3 buttons... found at least 4...");

            mockModel2.append({title: "humppa", iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon4.qml", indicatorProperties: ""})
            overviewGrid.forceLayout();
            waitForRendering(overviewGrid);

            button = findChild(overview, "overviewGridButton3");
            verify(button !== undefined, "button3 wasn't found");
        }

        function test_volume_slider_data() {
            return [
                {tag: "0%", sliderPos:0},
                {tag: "100%", sliderPos: 100},
                {tag: "50%", sliderPos: 50}
            ];
        }

        function test_volume_slider(data) {
            var volumeSlider = findChild(overview, "volumeSlider");
            var startX = volumeSlider.width * volumeSlider.value / 100;
            var startY = volumeSlider.y + volumeSlider.height / 2;
            var stopX = (volumeSlider.width - units.gu(5)) * data.sliderPos / 100;
            var stopY = volumeSlider.y + volumeSlider.height / 2;
            mouseFlick(volumeSlider, startX, startY, stopX, stopY, true, true, 0.1);
        }

        function test_volume_buttons(data) {
            var volumeDownButton = findChild(overview, "minVolumeIcon");
            var volumeUpButton = findChild(overview, "maxVolumeIcon");

            for (var i = 0; i < 10; ++i) {
                mouseClick(volumeDownButton, volumeDownButton.width / 2, volumeDownButton.height / 2);
                wait(0)
            }
            tryCompare(volumeControl, "volume", 0);
            for (var i = 0; i < 10; ++i) {
                mouseClick(volumeUpButton, 1, 1);
                wait(0)
            }
        }
    }
}
