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
        title: "Testing rocks, debugging sucks!"

        buttons: Row {
            width: parent.width
            height: units.gu(5)
            Rectangle {
                width: parent.width / 3
                height: parent.height
                color: "blue"
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
            }
        }

        header: Label { text: "Caption label" }

        body: Column {
            id: testContent
            objectName: "testContent"
            width: parent.width
            height: units.gu(50)
            Rectangle {
                width: parent.width
                height: parent.height / 3
                color: "green"
            }
            Rectangle {
                width: parent.width
                height: parent.height / 3
                color: "red"
            }
            Rectangle {
                width: parent.width
                height: parent.height / 3
                color: "blue"
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

        function test_close() {
            var title = findChild(preview, "titleLabel")
            mouseClick(title, 1, 1)
            compare(closeSpy.count, 1, "Close signal not emitted")
        }

        function test_columns_data() {
            return [
                {tag: "1 columns", width: units.gu(5), height: units.gu(10), columns: 1},
                {tag: "2 columns", width: units.gu(50), height: units.gu(10), columns: 2}
            ]
        }

        function test_columns(data) {
            var leftCol = findChild(preview, "leftColumn")
            var rightCol = findChild(preview, "rightColumn")

            root.width = data.width
            root.height = data.height

            // there are 2 columns in DashPreview. On portrait form factors
            // only the left one is used and the right one should be empty.
            // to find out if the content is in the correct column, we get a
            // reference to the column objects and search only the subtree
            // to see if the content is in the correct column.
            // 1 colum  -> content should be in leftColumn
            // 2 colums -> content should be in rightColumn

            switch(data.columns) {
            case 1:
                var testContent = findChild(leftCol, "testContent")
                compare(testContent.objectName, "testContent")
                break
            case 2:
                var testContent = findChild(rightCol, "testContent")
                compare(testContent.objectName, "testContent")
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
