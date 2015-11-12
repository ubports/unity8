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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

ScopeSetting {
    id: root
    height: listItem.height

    property string mode: "string"

    ListItem.Empty {
        id: listItem
        onClicked: {
            control.forceActiveFocus();
            control.selectAll();
        }

        Label {
            id: label
            anchors {
                left: parent.left
                leftMargin: settingMargins
                right: control.left
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            text: widgetData.displayName
            elide: Text.ElideMiddle
            maximumLineCount: 2
            wrapMode: Text.Wrap
            color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
        }

        TextField {
            id: control
            objectName: "control"
            anchors {
                right: parent.right
                rightMargin: settingMargins
                verticalCenter: parent.verticalCenter
            }
            width: root.mode == "number" ? units.gu(8) : units.gu(12)
            text: widgetData.value
            color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.fieldText
            validator: root.mode == "number" ? doubleValidator : null
            hasClearButton: root.mode == "number" ? false : true

            DoubleValidator {
                id: doubleValidator
            }

            function updateText() {
                if (acceptableInput) {
                    text = displayText;
                    root.updated(text);
                }
            }

            onAccepted: updateText()
            onActiveFocusChanged: {
                if (!activeFocus) {
                    updateText();
                }
            }

            readonly property bool inputMethodVisible: Qt.inputMethod.visible
            onInputMethodVisibleChanged: {
                if(inputMethodVisible && activeFocus)
                    root.makeSureVisible(control);
            }
        }
    }
}
