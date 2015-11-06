/*
 * Copyright 2014,2015 Canonical Ltd.
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
import Ubuntu.Components 1.3
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: theme.palette.selected.background

    property var widgetDataComplete: {
        "title": "Title here longa long long long long long long long long long long",
        "values": [ [ "Long Label 1", "Long Value 1 Long Value 2 Long Value 3 Long Value 4 Long Value 5 Long Value 6 Long Value 2 Long Value 2 Long Value 2 Long Value 2"],  [ "Label 2", "Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2"],  [ "Label 3", "Value 3"],  [ "Label 4", "Value 4"],  [ "Label 5", "Value 5"] ]
    }

    property var widgetDataNoTitle: {
        "values": [ [ "Long Label 1", "Long Value 1 Long Value 2 Long Value 3 Long Value 4 Long Value 5 Long Value 6 Long Value 2 Long Value 2 Long Value 2 Long Value 2"],  [ "Label 2", "Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2"],  [ "Label 3", "Value 3"],  [ "Label 4", "Value 4"],  [ "Label 5", "Value 5"] ]
    }

    PreviewWidgetFactory {
        id: previewTable
        anchors { left: parent.left; right: parent.right }
        widgetType: "table"

        Rectangle {
            color: "red"
            anchors.fill: parent
            opacity: 0.5
        }

        Component.onCompleted: {
            previewTable.widgetData = widgetDataComplete
        }
    }

    UT.UnityTestCase {
        name: "PreviewTableTest"
        when: windowShown

        function init() {
            previewTable.widgetData = widgetDataComplete;
        }

        function test_label_heights() {
            verify(findChild(previewTable, "label00").height == findChild(previewTable, "label10").height);
            verify(findChild(previewTable, "label01").height == findChild(previewTable, "label11").height);
            verify(findChild(previewTable, "label01").height > findChild(previewTable, "label00").height * 3);
            verify(findChild(previewTable, "label00").height == findChild(previewTable, "label20").height);
            verify(findChild(previewTable, "label20").height == findChild(previewTable, "label21").height);
        }

        function test_values() {
            compare(findChild(previewTable, "label00").text, "Long Label 1");
            compare(findChild(previewTable, "label01").text, "Long Value 1 Long Value 2 Long Value 3 Long Value 4 Long Value 5 Long Value 6 Long Value 2 Long Value 2 Long Value 2 Long Value 2");
            compare(findChild(previewTable, "label10").text, "Label 2");
            compare(findChild(previewTable, "label11").text, "Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2 Long Value 2");
            compare(findChild(previewTable, "label20").text, "Label 3");
            compare(findChild(previewTable, "label21").text, "Value 3");
            compare(findChild(previewTable, "label30").text, "Label 4");
            compare(findChild(previewTable, "label31").text, "Value 4");
            compare(findChild(previewTable, "label40").text, "Label 5");
            compare(findChild(previewTable, "label41").text, "Value 5");
        }

        function test_optional_title() {
            var titleLabel = findChild(previewTable, "titleLabel");
            compare(titleLabel.visible, true);
            var titleHeight = titleLabel.height;
            var prevHeight = previewTable.height;

            previewTable.widgetData = widgetDataNoTitle;
            var column = findChild(previewTable, "column");
            tryCompare(previewTable, "height", prevHeight - titleHeight - column.spacing );
        }

        function test_show_collapsed() {
            verify(findChild(previewTable, "label00").visible);
            verify(findChild(previewTable, "label01").visible);
            verify(findChild(previewTable, "label10").visible);
            verify(findChild(previewTable, "label11").visible);
            verify(findChild(previewTable, "label20").visible);
            verify(findChild(previewTable, "label21").visible);
            verify(findChild(previewTable, "label30").visible);
            verify(findChild(previewTable, "label31").visible);
            verify(findChild(previewTable, "label40").visible);
            verify(findChild(previewTable, "label41").visible);

            waitForRendering(previewTable);
            var prevHeight = previewTable.height;
            previewTable.expanded = false;

            verify(findChild(previewTable, "label00").visible);
            verify(findChild(previewTable, "label01").visible);
            verify(findChild(previewTable, "label10").visible);
            verify(findChild(previewTable, "label11").visible);
            verify(findChild(previewTable, "label20").visible);
            verify(findChild(previewTable, "label21").visible);
            verify(!findChild(previewTable, "label30").visible);
            verify(!findChild(previewTable, "label31").visible);
            verify(!findChild(previewTable, "label40").visible);
            verify(!findChild(previewTable, "label41").visible);

            var labelHeight = findChild(previewTable, "label00").height;
            var gridLayout = findChild(previewTable, "gridLayout");
            tryCompare(previewTable, "height", prevHeight - labelHeight * 2 - gridLayout.rowSpacing * 2);
        }
    }
}
