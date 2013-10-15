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
import "../../../Dash"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(120)
    height: units.gu(80)

    property bool helper: false

    DashPreview {
        id: preview
        anchors.fill: parent

        previewImages: Rectangle {
            width: parent.width
            height: units.gu(20)
            color: "honeydew"
            Label {
                anchors.centerIn: parent
                text: "Preview images"
            }
        }

        header: Rectangle {
            width: parent.width
            height: units.gu(10)
            color: "papayawhip"
            Label {
                anchors.centerIn: parent
                text: "Caption label"
            }
        }

        actions: Row {
            width: parent.width
            height: units.gu(5)
            Rectangle {
                width: parent.width / 3
                height: parent.height
                color: "blue"
                Label {
                    anchors.centerIn: parent
                    text: "Button 1"
                }
                MouseArea {
                    id: buttonMouseArea
                    objectName: "buttonMouseArea"
                    anchors.fill: parent
                    onClicked: root.helper = true
                }
            }
            Rectangle {
                width: parent.width / 3
                height: parent.height
                color: "green"
                Label {
                    anchors.centerIn: parent
                    text: "Button 2"
                }

            }
        }

        description: Column {
            id: testContent
            objectName: "testContent"
            width: parent.width
            height: units.gu(50)
            Rectangle {
                width: parent.width
                height: parent.height / 3
                color: "green"
                Label {
                    anchors.centerIn: parent
                    text: "Description part 1"
                }
            }
            Rectangle {
                width: parent.width
                height: parent.height / 3
                color: "red"
                Label {
                    anchors.centerIn: parent
                    text: "Description part 2"
                }
            }
            Rectangle {
                width: parent.width
                height: parent.height / 3
                color: "blue"
                Label {
                    anchors.centerIn: parent
                    text: "Description part 3"
                }
            }
        }

        ratings: Rectangle {
            objectName: "ratings"
            width: parent.width
            height: units.gu(20)
            Label {
                anchors.centerIn: parent
                text: "Ratings"
            }
        }
    }

    SignalSpy {
        id: closeSpy
        target: preview
        signalName: "close"
    }

    SignalSpy {
        id: previewClickedSpy
        target: preview
        signalName: "previewImageClicked"
    }

    UT.UnityTestCase {
        name: "DashPreview"
        when: windowShown

        function test_columns_data() {
            return [
                {tag: "1 columns", width: units.gu(5), height: units.gu(10), columns: 1},
                {tag: "3 columns", width: units.gu(50), height: units.gu(10), columns: 3}
            ]
        }

        function test_columns(data) {
            var leftCol = findChild(preview, "leftColumn")
            var centerCol = findChild(preview, "centerColumn")
            var rightCol = findChild(preview, "rightColumn")

            root.width = data.width
            root.height = data.height

            // there are 3 columns in DashPreview. On portrait form factors
            // only the left one is used and the center and right ones should be empty.
            // To find out if the content is in the correct column, we get a
            // reference to the column objects and search only the subtree
            // to see if the content is in the correct column.
            // 1 colum  -> all content should be in leftColumn
            // 3 colums -> content should be in centerColumn, rating in rightColumn

            switch(data.columns) {
            case 1:
                var testContent = findChild(leftCol, "testContent")
                compare(testContent.objectName, "testContent")
                testContent = findChild(leftCol, "ratings")
                compare(testContent.objectName, "ratings")
                break
            case 3:
                var testContent = findChild(centerCol, "testContent")
                compare(testContent.objectName, "testContent")
                testContent = findChild(rightCol, "ratings")
                compare(testContent.objectName, "ratings")
                break
            }

            // reset to initial values to not disturb other tests
            root.width = units.gu(120)
            root.height = units.gu(80)
        }

        // This test just checks if Components assigned to the
        // "buttons" property are actually put somewhere on the
        // screen. the mouseClick would fail if they are not used/painted
        function test_ensure_buttons_visible() {
            waitForRendering(preview)

            var button = findChild(preview, "buttonMouseArea")
            mouseClick(button, 1, 1)
            tryCompare(root, "helper", true)
            // reset to false in case any other test wants to use it
            root.helper = false
        }
    }
}
