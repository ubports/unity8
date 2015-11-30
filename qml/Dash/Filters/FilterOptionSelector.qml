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
import Ubuntu.Components.ListItems 1.3 as ListItems

/*! Option Selector Filter Widget. */

FilterWidget {
    id: root

    implicitHeight: expandingItem.height

    ListItems.Expandable {
        id: expandingItem
        objectName: "expandingItem"

        expandedHeight: collapsedHeight + column.height
        width: parent.width

        onClicked: {
            expanded = !expanded;
        }

        Item {
            id: holder
            anchors.top: parent.top
            height: expandingItem.collapsedHeight
            width: parent.width

            Label {
                anchors.left: parent.left
                anchors.right: dropDown.left
                anchors.verticalCenter: parent.verticalCenter
                text: widgetData.label || ""
            }

            Image {
                id: dropDown
                height: units.gu(3)
                fillMode: Image.PreserveAspectFit
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: expandingItem.expanded ? "image://theme/up" : "image://theme/down"
            }
        }

        Column {
            id: column
            anchors.top: holder.bottom
            width: parent.width
            Repeater {
                model: widgetData.options

                ListItems.Standard {
                    text: label
                    objectName: root.objectName + "label" + index;

                    Image {
                        height: units.gu(3)
                        fillMode: Image.PreserveAspectFit
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/tick"
                        visible: checked
                    }

                    onClicked: {
                        widgetData.options.setChecked(index, !checked);
                    }
                }
            }
        }
    }
}
