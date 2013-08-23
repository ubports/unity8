/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators

Indicators.IndicatorWidget {
    id: indicatorWidget

    width: itemRow.width + units.gu(0.7)

    property alias leftLabel: itemLeftLabel.text
    property alias rightLabel: itemRightLabel.text
    property var icons: undefined

    Row {
        id: itemRow
        objectName: "itemRow"
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(0.5)

        Label {
            id: itemLeftLabel
            objectName: "leftLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
        }

        Row {
            width: childrenRect.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            spacing: units.gu(0.5)

            Repeater {
                model: indicatorWidget.icons

                Image {
                    id: itemImage
                    objectName: "itemImage"
                    visible: source != ""
                    source: modelData
                    height: indicatorWidget.iconSize
                    width: indicatorWidget.iconSize
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Label {
            id: itemRightLabel
            objectName: "rightLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
        }
    }

    onActionStateChanged: {
        if (actionState == undefined) {
            label = "";
            iconSource = "";
            enabled = false;
            return;
        }

        leftLabel = actionState.leftLabel ? actionState.leftLabel : "";
        rightLabel = actionState.rightLabel ? actionState.rightLabel : "";
        icons = actionState.icons;
        enabled = actionState.visible;
    }
}
