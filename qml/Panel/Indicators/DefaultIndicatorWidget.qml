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
import Ubuntu.Settings.Components 0.1
import Unity.Indicators 0.1 as Indicators

Indicators.IndicatorBase {
    id: indicatorWidget

    property int iconSize: units.gu(2)
    property alias leftLabel: itemLeftLabel.text
    property alias rightLabel: itemRightLabel.text
    property var icons: undefined

    width: itemRow.width
    enabled: false

    Row {
        id: itemRow
        objectName: "itemRow"
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: itemLeftLabel
            width: paintedWidth + units.gu(1)
            objectName: "leftLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
            horizontalAlignment: Text.AlignHCenter
        }

        Row {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            Repeater {
                model: indicatorWidget.icons

                Item {
                    width: itemImage.width + units.gu(1)
                    anchors { top: parent.top; bottom: parent.bottom }

                    StatusIcon {
                        id: itemImage
                        height: indicatorWidget.iconSize
                        anchors.centerIn: parent
                        source: modelData
                        sets: ["status"]
                        color: "#CCCCCC"
                    }
                }
            }
        }

        Label {
            id: itemRightLabel
            width: paintedWidth + units.gu(1)
            objectName: "rightLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
            horizontalAlignment: Text.AlignHCenter
        }
    }

    onRootActionStateChanged: {
        if (rootActionState == undefined) {
            leftLabel = "";
            rightLabel = "";
            icons = undefined;
            enabled = false;
            return;
        }

        leftLabel = rootActionState.leftLabel ? rootActionState.leftLabel : "";
        rightLabel = rootActionState.rightLabel ? rootActionState.rightLabel : "";
        icons = rootActionState.icons;
        enabled = rootActionState.visible;
    }
}
