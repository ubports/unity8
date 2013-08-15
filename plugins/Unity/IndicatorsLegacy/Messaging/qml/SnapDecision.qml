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
import Unity.IndicatorsLegacy 0.1 as Indicators
import "utils.js" as Utils

HeroMessage {
    id: snapDecision

    expandedHeight: buttons.y + buttons.height + quickreply.height + units.gu(2)
    heroMessageHeader.titleText.text:  menu ? menu.label : ""
    heroMessageHeader.subtitleText.text: menu ? menu.extra.canonical_text : ""
    heroMessageHeader.subtitleText.color: "#e8e1d0"
    heroMessageHeader.bodyText.text: menu ? Utils.formatDate(menu.extra.canonical_time) : ""
    heroMessageHeader.bodyText.color: "#8f8f88"

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

        ActionButton {
            actionGroup: snapDecision.actionGroup
            action: actionsDescription[0].name

            text: actionsDescription ?  actionsDescription[0].label : "Call back"
            color: "#c94212"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: (parent.width - units.gu(1)) / 2
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

        actionGroup: snapDecision.actionGroup
        action: actionsDescription[1].name

        messages: actionsDescription ? actionsDescription[1]["parameter-hint"] : ""
        buttonText: actionsDescription ? actionsDescription[1].label : "send"
        anchors {
            top: buttons.bottom
            topMargin: units.gu(2)
            left: parent.left
            right: parent.right
        }
        height: 0
        opacity: 0.0
        enabled: false

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
