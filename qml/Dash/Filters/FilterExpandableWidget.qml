/*
 * Copyright (C) 2016 Canonical, Ltd.
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

/*! Expandable Filter Widget. */

FilterWidget {
    id: root

    showsTitleOnItsOwn: true

    implicitHeight: expandingItem.height

    ListItems.Expandable {
        id: expandingItem
        objectName: "expandingItem"

        expandedHeight: collapsedHeight + column.height
        anchors.left: parent.left
        anchors.right: parent.right
        showDivider: false

        onClicked: {
            expanded = !expanded;
            forceActiveFocus();
        }
        __contentsMargins: 0

        Item {
            id: titleHolder
            anchors.top: parent.top
            height: expandingItem.collapsedHeight
            anchors.left: parent.left
            anchors.right: parent.right

            Label {
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                anchors.right: dropDown.left
                anchors.verticalCenter: parent.verticalCenter
                text: widgetData.title || ""
            }

            Image {
                id: dropDown
                height: units.gu(3)
                fillMode: Image.PreserveAspectFit
                anchors.right: parent.right
                anchors.rightMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                source: expandingItem.expanded ? "image://theme/up" : "image://theme/down"
                sourceSize.height: height
            }
        }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: titleHolder.bottom

            Repeater {
                id: repeater
                model: widgetData.filters

                delegate: FilterWidgetFactory {
                    width: parent.width

                    widgetId: id
                    widgetType: type
                    widgetData: filter

                    ListItems.ThinDivider {
                        anchors.bottom: parent.bottom
                        visible: index !== repeater.count - 1
                    }
                }
            }
        }
    }
}
