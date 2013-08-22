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

Indicators.BaseMenuItem {
    id: heroMessage

    property var actionsDescription: menu ? menu.ext.xCanonicalMessageActions : undefined
    property alias heroMessageHeader: __heroMessageHeader
    property real collapsedHeight: heroMessageHeader.y + heroMessageHeader.bodyBottom + units.gu(2)
    property real expandedHeight: collapsedHeight

    property alias avatar: __heroMessageHeader.avatar
    property alias appIcon: __heroMessageHeader.icon

    signal activateApp
    signal dismiss

    removable: state !== "expanded"
    implicitHeight: collapsedHeight

    HeroMessageHeader {
        id: __heroMessageHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        avatar: "qrc:/indicators/artwork/messaging/default_contact.png"
        appIcon: icon

        state: heroMessage.state

        onAppIconClicked:  {
            deselectMenu();
            heroMessage.activateApp();
        }
    }

    onClicked: {
        if (menuSelected) {
            deselectMenu();
        } else {
            selectMenu();
        }
    }

    Indicators.HLine {
        id: __topHLine
        anchors.top: parent.top
        color: "#403b37"
    }

    Indicators.HLine {
        id: __bottomHLine
        anchors.bottom: parent.bottom
        color: "#060606"
    }

    states: State {
        name: "expanded"
        when: menuSelected

        PropertyChanges {
            target: heroMessage
            color: "#333130"
            implicitHeight: heroMessage.expandedHeight
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
        heroMessage.dismiss();
    }
}
