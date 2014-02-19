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
    /*!
     \preliminary
     The text that is shown as the header text.
     \qmlproperty string text
    */
    property alias text: label.text
    property alias image: image.source

    signal clicked(variant mouse)

    height: units.gu(5)

    Item {
        anchors {
            left: parent.left
            right: parent.right
            rightMargin: units.gu(0.5)
            top: parent.top
            bottom: parent.bottom
        }

        Label {
            id: label
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }

            color: "grey" // TODO karni: Update Ubuntu.Compoonents.Themes.Palette.
            font.family: "Ubuntu"
            fontSize: "medium"
            elide: Text.ElideRight
            textFormat: Text.PlainText
            width: parent.width - image.width - image.leftMargin - anchors.leftMargin
        }

        Image {
            id: image
            readonly property double leftMargin: units.gu(1)
            x: label.x + label.contentWidth + leftMargin
            anchors {
                verticalCenter: parent.verticalCenter
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked(mouse)
    }
}
