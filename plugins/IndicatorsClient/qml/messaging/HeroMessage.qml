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
import IndicatorsClient 0.1 as IndicatorsClient

IndicatorsClient.BasicMenu {
    id: __heroMessage

    property variant actionsDescription: null
    property variant action: menu && actionGroup ? actionGroup.action(menu.action) : undefined
    property alias heroMessageHeader: __heroMessageHeader
    property real collapsedHeight: heroMessageHeader.y + heroMessageHeader.bodyBottom + units.gu(2)
    property real expandedHeight: collapsedHeight

    color: "#221e1c"

    removable: state !== "expanded"
    implicitHeight: collapsedHeight

    HeroMessageHeader {
        id: __heroMessageHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        avatar: menu && (menu.extra.canonical_icon.length > 0) ? "image://gicon/" + encodeURI(menu.extra.canonical_icon) : "qrc:/indicatorsclient/artwork/messaging/default_contact.png"
        icon: menu && (menu.extra.canonical_app_icon.length > 0) ? "image://gicon/" + encodeURI(menu.extra.canonical_app_icon) : ""
        appIcon: icon

        state: __heroMessage.state

        onAppIconClicked:  {
            if (action && action.valid) {
                listViewSelectItem(-1)
                action.activate(true)
            }
        }
    }

    onClicked: {
        if (listViewIsCurrentItem) {
            listViewSelectItem(-1)
        } else {
            listViewSelectItem(index)
        }
    }

    IndicatorsClient.HLine {
        id: __topHLine
        anchors.top: parent.top
        color: "#403b37"
    }

    IndicatorsClient.HLine {
        id: __bottomHLine
        anchors.bottom: parent.bottom
        color: "#060606"
    }

    states: State {
        name: "expanded"
        when: listViewIsCurrentItem

        PropertyChanges {
            target: __heroMessage
            color: "#333130"
            implicitHeight: __heroMessage.expandedHeight
        }
        PropertyChanges {
            target: __topHLine
            opacity: 0.0
        }
        PropertyChanges {
            target: __bottomHLine
            opacity: 0.0
        }
    }

    transitions: Transition {
        ParallelAnimation {
            NumberAnimation {
                properties: "opacity,implicitHeight"
                duration: 200
                easing.type: Easing.OutQuad
            }
            ColorAnimation {}
        }
    }

    onItemRemoved: {
        if (action && action.valid) {
            action.activate(false)
        }
    }
}
