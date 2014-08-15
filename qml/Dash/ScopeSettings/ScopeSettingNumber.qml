/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

ScopeSetting {
    id: root
    height: listItem.height

    ListItem.Empty {
        id: listItem
        onClicked: {
            control.forceActiveFocus();
            control.selectAll();
        }

        Label {
            anchors {
                left: parent.left
                leftMargin: __margins
                right: control.left
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            text: widgetData.displayName
            elide: Text.ElideMiddle
            color: scopeStyle ? scopeStyle.foreground : "grey"
        }

        TextField {
            id: control
            objectName: "control"
            anchors {
                right: parent.right
                rightMargin: __margins
                verticalCenter: parent.verticalCenter
            }
            text: widgetData.value
            width: units.gu(8)
            validator: DoubleValidator {}
            hasClearButton: false

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
        }
    }
}
