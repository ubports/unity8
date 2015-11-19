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

    ListItem.Empty {
        id: listItem

        onClicked: {
            control.checked = !control.checked;
            updated(control.checked);
        }

        Label {
            anchors {
                left: parent.left
                leftMargin: settingMargins
                right: control.left
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            // TODO The translation should ideally come from the bottom layers and not be hardcoded here
            // https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1393438
            text: widgetData.settingId == "internal.location" ? i18n.tr("Enable location data") : widgetData.displayName
            elide: Text.ElideMiddle
            maximumLineCount: 2
            wrapMode: Text.Wrap
            color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
        }

        CheckBox {
            id: control
            objectName: "control"
            anchors {
                right: parent.right
                rightMargin: settingMargins
                verticalCenter: parent.verticalCenter
            }
            checked: widgetData.value

            onTriggered: root.updated(checked)
        }
    }
}
