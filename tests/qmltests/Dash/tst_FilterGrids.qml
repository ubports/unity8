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
import "../../../qml/Dash/Video"
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
                onClicked: gridLoader.source = "../../../qml/Dash/" + testCase.test_clicked_signal_data()[index].component
            }
        }
    }

    ListModel {
        id: fakeModel
        ListElement { icon: "../../graphics/clock.png"; title: "Item0"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item1"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item2"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item3"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item4"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item5"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item6"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item7"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item8"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item9"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item10"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item11"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item12"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item13"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item14"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item15"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item16"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item17"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item18"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
        ListElement { icon: "../../graphics/clock.png"; title: "Item19"; comment: ""; uri: "dummy.desktop"; dndUri: "dummy.desktop" }
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
                {tag: "VideoFilterGrid", component: "Video/VideoFilterGrid.qml"},
                {tag: "MusicFilterGrid", component: "Music/MusicFilterGrid.qml"}
            ]
        }

        function test_clicked_signal(data) {
            gridLoader.source = "";
            gridLoader.source = "../../../qml/Dash/" + data.component;

            // Wait until the FilterGrid is loaded by the loader
            tryCompare(gridLoader, "status", Loader.Ready);

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
