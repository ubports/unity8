/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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

/*! This preview widget shows either one button, two buttons or one button
 *  and a combo button depending on the number of items in widgetData["actions"].
 *  For each of the items we recognize the fields "label", "icon" and "id".
 */

PreviewWidget {
    id: root

    implicitHeight: row.height + units.gu(1)

    Row {
        id: row
        readonly property var actions: root.widgetData ? root.widgetData["actions"] : null
        anchors.right: parent.right

        spacing: units.gu(1)

        Loader {
            id: loader
            readonly property bool button: row.actions && row.actions.length == 2
            readonly property bool combo: row.actions && row.actions.length > 2
            source: button ? "PreviewActionButton.qml" : (combo ? "PreviewActionCombo.qml" : "")
            width: (root.width - units.gu(1)) / 2
            onLoaded: {
                if (button) {
                    item.data = row.actions[1];
                } else if (combo) {
                    item.model = row.actions.slice(1);
                }
            }
            Binding {
                target: loader.item
                property: "strokeColor"
                value: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText
            }
            Connections {
                target: loader.item
                onTriggeredAction: {
                    root.triggered(root.widgetId, actionData.id, actionData);
                }
            }
        }

        PreviewActionButton {
            data: visible ? row.actions[0] : null
            visible: row.actions && row.actions.length > 0
            onTriggeredAction: root.triggered(root.widgetId, actionData.id, actionData)
            width: (root.width - units.gu(1)) / 2
            color: root.scopeStyle ? root.scopeStyle.previewButtonColor : UbuntuColors.orange
        }
    }
}
