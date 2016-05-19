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

/*! This preview widget icons+label for number of items in widgetData["actions"].
 *  For each of the items we recognize the fields "label", "icon", "temporaryIcon" and "id".
 *  temporaryIcon is the icon that will be shown just after the user presses icon until the
 *  scope refreshes the preview
 */

PreviewWidget {
    id: root

    implicitHeight: row.height

    Row {
        id: row
        readonly property var actions: root.widgetData ? root.widgetData["actions"] : null
        width: parent.width
        onActionsChanged: {
            // Rewire the source since it may have been unwired on onClicked
            // but the icon didn't change i.e. the scope updated the results
            // and the icon needs to go back to the one it was originally
            for (var i = 0; i < repeater.count; ++i) {
                var button = repeater.itemAt(i);
                button.updateIcon();
            }
        }

        spacing: units.gu(2)

        Repeater {
            id: repeater
            model: row.actions

            AbstractButton {
                objectName: "button" + modelData.id
                height: label.height
                width: childrenRect.width

                readonly property var iconUrl: modelData.icon;
                function updateIcon() {
                    icon.source = iconUrl;
                }

                Image {
                    id: icon
                    height: parent.height
                    width: height
                    source: modelData.icon
                    sourceSize { width: icon.width; height: icon.height }
                }

                Label {
                    id: label
                    anchors.left: icon.right
                    anchors.leftMargin: visible ? units.gu(0.5) : 0
                    text: modelData.label
                    visible: text !== ""
                }

                onClicked: {
                    if (modelData.temporaryIcon) {
                        icon.source = modelData.temporaryIcon;
                    }
                    root.triggered(root.widgetId, modelData.id, modelData);
                }
            }
        }
    }

}
