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
import Ubuntu.Components 0.1
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: Theme.palette.selected.background

    property string longText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh."
    property string longText2: "This is a very very very long text. 1 This is a very very very long text. 2 This is a very very very long text. 3 This is a very very very long text. 4 This is a very very very long text. 5 This is a very very very long text. 6 This is a very very very long text. 7 This is a very very very long text. 8 This is a very very very long text. 9 This is a very very very long text. 10 This is a very very very long text. 11 This is a very very very long text."
    property string shortText: "This is a short text :)"

    property var tableData: {
        "values": [ [ "Long Label 1", "Value 1"],  [ "Label 2", "Long Value 2"],  [ "Label 3", "Value 3"],  [ "Label 4", "Value 4"],  [ "Label 5", "Value 5"] ]
    }

    property var widgetData: {
        "title": "Title here",
        "collapsed-widgets": 2,
        "widgets": [
            { "type": "text", "widgetId" : "text1", "properties" : { "text": longText } },
            { "type": "table", "widgetId" : "table1", "properties" : tableData },
            { "type": "text", "widgetId" : "text3", "properties" : { "text": shortText } },
            { "type": "text", "widgetId" : "text4", "properties" : { "text": longText } }
        ]
    }

    PreviewExpandable {
        id: previewExpandable
        anchors { left: parent.left; right: parent.right }
        widgetData: root.widgetData
    }

    UT.UnityTestCase {
        name: "PreviewExpandableTest"
        when: windowShown

        function checkInitialState()
        {
            compare(previewExpandable.expanded, false);

            var repeater = findChild(previewExpandable, "repeater")
            compare(repeater.count, 4)

            compare (repeater.itemAt(0).visible, true);
            compare (repeater.itemAt(1).visible, true);
            compare (repeater.itemAt(2).visible, false);
            compare (repeater.itemAt(3).visible, false);
            compare (repeater.itemAt(0).expanded, false);
            compare (repeater.itemAt(1).expanded, false);
        }

        function init() {
        }

        function test_collapsed_by_default() {
            // Nothing init does this already
        }

        function test_expand_collapse() {
            var expandButton = findChild(previewExpandable, "expandButton")
            mouseClick(expandButton, expandButton.width / 2, expandButton.height / 2);

            var repeater = findChild(previewExpandable, "repeater")
            compare(repeater.count, 4)

            compare (repeater.itemAt(0).visible, true);
            compare (repeater.itemAt(1).visible, true);
            compare (repeater.itemAt(2).visible, true);
            compare (repeater.itemAt(3).visible, true);
            compare (repeater.itemAt(0).expanded, true);
            compare (repeater.itemAt(1).expanded, true);
            compare (repeater.itemAt(2).expanded, true);
            compare (repeater.itemAt(3).expanded, true);

            mouseClick(expandButton, expandButton.width / 2, expandButton.height / 2);

            checkInitialState();
        }
    }
}
