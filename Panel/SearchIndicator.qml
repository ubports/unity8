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
import "../Components"

Item {
    id: search

    width: units.gu(9)
    height: units.gu(3)

    property string headerText: i18n.tr("Search")

    signal clicked

    // eater
    MouseArea {
        anchors.fill: parent
        onClicked: search.clicked()
    }

    Item {
        id: container
        objectName: "container"

        width: parent.width
        height: parent.height

        Behavior on opacity { StandardAnimation {} }

        Image {
            id: icon
            source: "graphics/search.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: units.gu(1)
        }

        Label {
            text: search.headerText
            color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
            fontSize: "small"
            font.capitalization: Font.AllUppercase
            anchors.left: icon.right
            anchors.leftMargin: units.gu(1)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: container
                opacity: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: container
                opacity: 0
            }
        }
    ]
}
