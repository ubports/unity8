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

    width: container.width + units.gu(2)
    height: units.gu(3)

    property string headerText: i18n.tr("Search")
    readonly property alias mouseArea: __mouseArea

    // eater
    MouseArea {
        id: __mouseArea
        anchors.fill: parent
    }

    Row {
        id: container
        objectName: "container"

        height: parent.height
        width: childrenRect.width
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
        }
        spacing: units.gu(1)

        Behavior on opacity { StandardAnimation { duration: 300 } }

        Image {
            id: icon
            source: "graphics/search.png"
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            text: search.headerText
            color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
            fontSize: "small"
            font.capitalization: Font.AllUppercase
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
