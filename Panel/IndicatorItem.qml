/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: indicatorItem

    property alias iconSource: itemImage.source
    property alias label: itemLabel.text
    property bool highlighted: false
    property bool dimmed: false

    // only visible when non-empty
    visible: label != "" || iconSource != ""
    width: itemRow.width + units.gu(1)

    Rectangle {
        color: "#dd4814"
        height: units.dp(2)
        width: parent.width
        anchors.top: parent.bottom
        visible: highlighted
    }

    Row {
        id: itemRow
        objectName: "itemRow"
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(0.5)
        opacity: dimmed ? 0.4 : 1

        Image {
            id: itemImage
            objectName: "itemImage"
            visible: source != ""
            height: units.gu(2.5)
            width: units.gu(2.5)
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: itemLabel
            objectName: "itemLabel"
            color: "#f3f3e7"
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
