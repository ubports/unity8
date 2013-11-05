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
import Unity.Indicators 0.1 as Indicators
import Unity.Indicators 0.1

HeroMessage {
    id: snapDecision

    property string title: ""
    property var time
    property string message: ""

    property bool activateEnabled: true
    property alias actionButtonText: actionButton.text

    property bool replyEnabled: true
    property alias replyMessages: quickreply.messages
    property alias replyButtonText: quickreply.buttonText

    expandedHeight: buttons.y + buttons.height + quickreply.height + units.gu(2)
    heroMessageHeader.titleText.text:  title
    heroMessageHeader.subtitleText.text: message
    heroMessageHeader.subtitleText.color: "#e8e1d0"
    heroMessageHeader.bodyText.text: timeFormatter.timeString
    heroMessageHeader.bodyText.color: "#8f8f88"

    signal activate
    signal reply(string value)

    Item {
        id: buttons

        anchors.left: parent.left
        anchors.leftMargin: units.gu(2)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        anchors.top: heroMessageHeader.bottom
        anchors.topMargin: units.gu(1)
        height: units.gu(4)
        opacity: 0.0

        TimeFormatter {
            id: timeFormatter
            time: snapDecision.time
            format: "hh:mm - MMM dd"
        }

        Button {
            text: "Message"
            color: "#bababa"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: (parent.width - units.gu(1)) / 2

            onClicked: {
                if (quickreply.state === "") {
                    quickreply.state = "expanded";
                } else {
                    quickreply.state = "";
                }
            }
        }

        Button {
            id: actionButton
            text: "Call back"
            color: enabled ? "#c94212" : "#bababa"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: (parent.width - units.gu(1)) / 2
            enabled: snapDecision.activateEnabled

            onClicked: {
                snapDecision.activate();
            }
        }

        states: State {
            name: "expanded"
            when: snapDecision.state === "expanded"

            PropertyChanges {
                target: buttons
                opacity: 1.0
            }
        }
        transitions: Transition {
            NumberAnimation {
                property: "opacity"
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    QuickReply {
        id: quickreply

        onReply: {
            snapDecision.reply(value);
        }

        messages: ""
        buttonText: "Send"
        anchors {
            top: buttons.bottom
            topMargin: units.gu(2)
            left: parent.left
            right: parent.right
        }
        height: 0
        opacity: 0.0
        enabled: false
        replyEnabled: snapDecision.replyEnabled

        states: State {
            name: "expanded"

            PropertyChanges {
                target: quickreply
                height: expandedHeight
                opacity: 1.0
            }

            PropertyChanges {
                target: quickreply
                enabled: true
            }
        }

        transitions: Transition {
            NumberAnimation {
                properties: "opacity,height"
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    onStateChanged: {
        if (state === "") {
            quickreply.state = "";
        }
    }
}
