/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Item {
    property alias text: label.text
    property alias color: label.color
    property alias iconName: icon.name

    signal clicked(variant mouse)

    height: units.gu(5)

    RowLayout {
        spacing: units.gu(.5)
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: units.gu(1)
        }

        Label {
            id: label
            Layout.fillWidth: true

            font.family: "Ubuntu"
            fontSize: "medium"
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
            width: Math.min(parent.width - units.gu(4), implicitWidth)
        }

        Icon {
            id: icon
            visible: name != ""
            height: units.gu(2)
            width: height
            color: label.color
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked(mouse)
    }
}
