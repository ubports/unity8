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
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.2 as ListItems

/*! Option Selector Filter Widget. */

FilterWidget {
    implicitHeight: expandingItem.height

    ListItems.Expandable {
        id: expandingItem
        // TODO ↑ ↓ button

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
                anchors.verticalCenter: parent.verticalCenter
                text: widgetData.label
            }
        }

        Column {
            id: column
            anchors.top: holder.bottom
            width: parent.width
            Repeater {
                model: widgetData.options

                ListItems.Standard {
                    // TODO checked
                    text: label
                }
            }
        }
    }
}
