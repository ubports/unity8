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
import Unity.Indicators 0.1

HeroMessage {
    id: __heroMessage

    property string title: ""
    property var time
    property string message: ""

    property alias footer: footerLoader.sourceComponent

    expandedHeight: fullMessage.y + fullMessage.height + units.gu(2)
    heroMessageHeader.titleText.text: title
    heroMessageHeader.subtitleText.text: timeFormatter.timeString
    heroMessageHeader.bodyText.text: message

    Item {
        id: fullMessage

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            top: heroMessageHeader.bottom
        }
        height: childrenRect.height
        opacity: 0.0
        enabled: false

        TimeFormatter {
            id: timeFormatter
            time: __heroMessage.time
            format: "hh:mm - MMM dd"
        }

        Label {
            id: bodyText
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: "#e8e1d0"
            fontSize: "medium"
            text: heroMessageHeader.bodyText.text
        }

        Loader {
            id: footerLoader

            anchors {
                top: bodyText.bottom
                topMargin: units.gu(2)
                left: parent.left
                right: parent.right
            }
            height: item != undefined ? units.gu(4) : 0
        }

        states: State {
            name: "expanded"
            when: __heroMessage.state === "expanded"

            PropertyChanges {
                target: heroMessageHeader.bodyText
                opacity: 0.0
            }

            PropertyChanges {
                target: fullMessage
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
