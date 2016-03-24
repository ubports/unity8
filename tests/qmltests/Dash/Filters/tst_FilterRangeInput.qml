/*
 * Copyright 2015 Canonical Ltd.
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
import "../../../../qml/Dash/Filters"
import Unity.Test 0.1 as UT
import Unity 0.2

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)
    color: theme.palette.selected.background

    QtObject {
        id: widgetData1

        property string title
        property real startValue
        property real endValue
        property bool hasStartValue
        property bool hasEndValue
        property string startPrefixLabel
        property string startPostfixLabel
        property string centralLabel
        property string endPrefixLabel
        property string endPostfixLabel

        onStartValueChanged: {
            hasStartValue = true;
        }

        onEndValueChanged: {
            hasEndValue = true;
        }

        function eraseStartValue() {
            hasStartValue = false;
        }

        function eraseEndValue() {
            hasEndValue = false;
        }
    }

    Component.onCompleted: {
        generateData();
    }

    function generateData() {
        widgetData1.title = title.text
        widgetData1.startValue = startValue.text;
        widgetData1.endValue = endValue.text;
        widgetData1.hasStartValue = startValueHasValue.checked;
        widgetData1.hasEndValue  = endValueHasValue.checked;
        widgetData1.startPrefixLabel = startValuePrefixLabel.text;
        widgetData1.startPostfixLabel = startValuePostfixLabel.text;
        widgetData1.centralLabel = centralLabel.text;
        widgetData1.endPrefixLabel = endValuePrefixLabel.text;
        widgetData1.endPostfixLabel = endValuePostfixLabel.text;

        factory.widgetData = widgetData1;
    }

    FilterWidgetFactory {
        id: factory
        widgetId: "testRangeInputFilter"
        widgetType: Filters.RangeInputFilter
        anchors {
            left: parent.left
            right: parent.right
        }
        clip: true
    }

    Column {
        anchors.top: factory.bottom
        width: parent.width
        spacing: units.gu(1)

        Text {
            text: "Values"
        }

        Row {
            spacing: units.gu(1)
            Text {
                text: "Title"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: title
                text: ""
            }
        }

        Row {
            spacing: units.gu(1)
            Text {
                text: "Start Value Prefix Label"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: startValuePrefixLabel
                text: "Pre1"
            }
        }

        Row {
            spacing: units.gu(1)
            Text {
                text: "Start Value Postfix Label"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: startValuePostfixLabel
                text: "Post1"
            }
        }

        Row {
            spacing: units.gu(1)
            Text {
                text: "Central Label"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: centralLabel
                text: "to"
            }
        }

        Row {
            spacing: units.gu(1)
            Text {
                text: "End Value Prefix Label"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: endValuePrefixLabel
                text: "Pre2"
            }
        }

        Row {
            spacing: units.gu(1)
            Text {
                text: "End Value Postfix Label"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: endValuePostfixLabel
                text: "Post2"
            }
        }

        Row {
            spacing: units.gu(1)
            Text {
                text: "Start Value"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: startValue
                text: "-1"
            }
            CheckBox {
                id: startValueHasValue
            }
        }


        Row {
            spacing: units.gu(1)
            Text {
                text: "End Value"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
            }
            TextField {
                id: endValue
                text: "5"
            }
            CheckBox {
                id: endValueHasValue
                checked: true
            }
        }

        Button {
            text: "Set Values"
            onClicked: root.generateData();
        }
    }

    UT.UnityTestCase {
        name: "FilterRangeInput"
        when: windowShown

        function init() {
            root.generateData();
        }

        function test_initialStatus() {
            var startValueField = findChild(factory, "startValueField");
            compare(startValueField.text, "");

            var endValueField = findChild(factory, "endValueField");
            compare(endValueField.text, "5");
        }

        function test_dotStays() {
            var startValueField = findChild(factory, "startValueField");
            compare(startValueField.text, "");

            startValueField.text = "4.5";
            compare(startValueField.text, "4.5");
            compare(widgetData1.startValue, 4.5);

            startValueField.text = "4.";
            compare(startValueField.text, "4.");
            compare(widgetData1.startValue, 4);
        }
    }
}
