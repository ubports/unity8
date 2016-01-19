/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

/*! Range Input Filter Widget. */

FilterWidget {
    id: root

    implicitHeight: field1.height + units.gu(2)

    function setFieldValue(field, hasValue, value) {
        if (hasValue) {
            // Need this othewise if we are on 4.5 and backspace instead of
            // having 4. in the text field we end up with 4 which is confusing
            if (field.text != value) {
                field.text = value;
            }
        } else {
            field.text = "";
        }
    }

    Connections {
        target: widgetData
        onStartValueChanged: root.setFieldValue(field1, widgetData.hasStartValue, widgetData.startValue);
        onHasStartValueChanged: root.setFieldValue(field1, widgetData.hasStartValue, widgetData.startValue);
        onEndValueChanged: root.setFieldValue(field2, widgetData.hasEndValue, widgetData.endValue);
        onHasEndValueChanged: root.setFieldValue(field2, widgetData.hasEndValue, widgetData.endValue);
    }

    onWidgetDataChanged: {
        if (widgetData) {
            root.setFieldValue(field1, widgetData.hasStartValue, widgetData.startValue);
            root.setFieldValue(field2, widgetData.hasEndValue, widgetData.endValue);
        } else {
            root.setFieldValue(field1, false, -1);
            root.setFieldValue(field2, false, -1);
        }
    }

    RowLayout {
        anchors {
            fill: parent
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: widgetData.startPrefixLabel
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: field1
            objectName: "startValueField"
            implicitWidth: units.gu(9)
            verticalAlignment: Text.AlignVCenter
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator {
                notation: DoubleValidator.StandardNotation
            }
            onTextChanged: {
                if (text === "") widgetData.eraseStartValue();
                else widgetData.startValue = text;
            }
        }

        Label {
            text: widgetData.startPostfixLabel
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: widgetData.centralLabel
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: widgetData.endPrefixLabel
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: field2
            objectName: "endValueField"
            implicitWidth: units.gu(9)
            verticalAlignment: Text.AlignVCenter
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator {
                notation: DoubleValidator.StandardNotation
            }
            onTextChanged: {
                if (text === "") widgetData.eraseEndValue();
                else widgetData.endValue = text;
            }
        }

        Label {
            text: widgetData.endPostfixLabel
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
