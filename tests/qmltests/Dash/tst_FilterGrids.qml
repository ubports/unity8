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
import "../../../Dash/Video"
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import "../"

Rectangle {
    id: shell
    width: gridRect.width + controls.width
    height: units.gu(50)
    color: "white"

    Column {
        id: controls
        width: units.gu(30)
        height: parent.height
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: units.gu(1)
        Label {
            id: spyLabel
            color: "blue"
            text: "Clicked item: [none]"
            anchors {left: parent.left; right: parent.right; margins: units.gu(1) }
        }
        Repeater {
            model: testCase.test_clicked_signal_data()
            Button {
                anchors {left: parent.left; right: parent.right; margins: units.gu(1) }
                text: testCase.test_clicked_signal_data()[index].tag
                onClicked: gridLoader.source = "../../../Dash/" + testCase.test_clicked_signal_data()[index].component
            }
        }
    }

    ListModel {
        id: fakeModel
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item0"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item1"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item2"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item3"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item4"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item5"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item6"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item7"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item8"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item9"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item10"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item11"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item12"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item13"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item14"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item15"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item16"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item17"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item18"; column_5: ""; column_6: "dummy.desktop" }
        ListElement { column_0: "Column0"; column_1: "../../graphics/clock.png"; column_4: "Item19"; column_5: ""; column_6: "dummy.desktop" }
    }

    Rectangle {
        id: gridRect
        width: units.gu(50)
        height: parent.height
        color: "grey"
        anchors.top: parent.top
        anchors.left: parent.left

        Loader {
            id: gridLoader
            anchors.fill: parent

            onProgressChanged: {
                if (progress == 1) {
                    item.model = fakeModel
                }
            }
        }

        Connections {
            target: gridLoader.item
            onClicked: spyLabel.text = "Clicked index: " + index
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "FilterGrids"
        when: windowShown

        function test_clicked_signal_data() {
            return [
                {tag: "VideosFilterGrid", component: "Video/VideosFilterGrid.qml"},
                {tag: "MusicFilterGrid", component: "Music/MusicFilterGrid.qml"},
                {tag: "ApplicationsFilterGrid", component: "Apps/ApplicationsFilterGrid.qml"}
            ]
        }

        function test_clicked_signal(data) {
            gridLoader.source = "";
            gridLoader.source = "../../../Dash/" + data.component;

            // Wait until the FilterGrid is loaded by the loader
            tryCompare(gridLoader, "status", Loader.Ready, "Loader couldn't load " + data.component);

            // Wait until the GridView inside the model has finished rendering
            var gridView = findChild(gridLoader, "responsiveGridViewGrid");
            gridView.forceLayout();
            waitForRendering(gridView);

            // Click item 1
            var tile1 = findChild(gridLoader.item, "delegate1");
            verify(tile1 !== undefined, "delegate1 wasn't found");
            clickedSpy.clear()
            mouseClick(tile1, tile1.width/2, tile1.height/2);

            // Check emission of clicked() signal with the according index as argument
            compare(clickedSpy.signalArguments[0][0], 1, "Clicked index is not the same as the one actually clicked")
        }
    }

    SignalSpy {
        id: clickedSpy
        signalName: "clicked"
        target: gridLoader.item
    }
}
