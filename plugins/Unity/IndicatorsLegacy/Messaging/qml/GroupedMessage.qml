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

Indicators.BasicMenuItem {
    id: groupedMessage
    property alias count: label.text

    color: "#221e1b"
    implicitHeight: units.gu(10)

    Indicators.MenuAction {
        id: menuAction
        actionGroup: groupedMessage.actionGroup
        action: menu ? menu.action : ""
    }

    Row {
        anchors.fill: parent
        anchors.margins: units.gu(2)
        spacing: units.gu(4)

        UbuntuShape {
            height: units.gu(6)
            width: units.gu(6)
            image: Image {
                source: menu && (menu.extra.canonical_icon.length > 0) ? "image://theme/" + encodeURI(menu.extra.canonical_icon) : "qrc:/indicators/artwork/messaging/default_app.svg"
                fillMode: Image.PreserveAspectFit
            }
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            color: "#e8e1d0"
            font.weight: Font.DemiBold
            fontSize: "medium"
            text: menu && menu.label ? menu.label : ""
        }

        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x
            horizontalAlignment: Text.AlignRight
            color: "#e8e1d0"
            font.weight: Font.DemiBold
            fontSize: "medium"
            text: menuAction.valid ? menuAction.state[0] : "0"
        }
    }

    Indicators.HLine {
        anchors.top: parent.top
        color: "#403b37"
    }

    Indicators.HLine {
        anchors.bottom: parent.bottom
        color: "#060606"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (menuAction.valid) {
                menuAction.activate(true);
            }
        }
    }

    onItemRemoved: {
        if (menuAction.valid) {
            menuAction.activate(false);
        }
    }
}
