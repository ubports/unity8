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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Olivier Tilloy <olivier.tilloy@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import "utils.js" as Utils

HeroMessage {
    id: __heroMessage

    property alias footer: __footer.sourceComponent

    expandedHeight: __fullMessage.y + __fullMessage.height + units.gu(2)
    heroMessageHeader.titleText.text: menu ? menu.label : ""
    heroMessageHeader.subtitleText.text: menu ? Utils.formatDate(menu.extra.canonical_time) : ""
    heroMessageHeader.bodyText.text: menu ? menu.extra.canonical_text : ""

    Item {
        id: __fullMessage

        anchors.left: parent.left
        anchors.leftMargin: units.gu(2)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        anchors.top: heroMessageHeader.bottom
        height: childrenRect.height
        opacity: 0.0
        enabled: false

        Label {
            id: __bodyText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: "#e8e1d0"
            fontSize: "medium"
            text: heroMessageHeader.bodyText.text
        }

        Loader {
            id: __footer

            anchors.top: __bodyText.bottom
            anchors.topMargin: units.gu(2)
            anchors.left: parent.left
            anchors.right: parent.right
            height: __footer.item != undefined ? units.gu(4) : 0
        }

        states: State {
            name: "expanded"
            when: __heroMessage.state === "expanded"

            PropertyChanges {
                target: heroMessageHeader.bodyText
                opacity: 0.0
            }

            PropertyChanges {
                target: __fullMessage
                opacity: 1.0
                enabled: true
            }
        }
        transitions: Transition {
            NumberAnimation {
                property: "opacity"
                duration: 200
            }
        }
    }
}
