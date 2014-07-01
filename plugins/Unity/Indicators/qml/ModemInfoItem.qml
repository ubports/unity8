/*
 * Copyright 2014 Canonical Ltd.
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
 *      Antti Kaijanmäki <antti.kaijanmaki@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Empty {
    id: menu
    implicitHeight: units.gu(5.5)

    property alias statusIcon: statusIcon.name
    property alias statusText: labelStatus.text
    property alias connectivityIcon: iconConnectivity.name
    property alias simIdentifierText: labelSimIdentifier.text
    property bool locked : false
    property bool roaming: false
    signal unlock

    Row {
        id: iconRow
        height: parent.height

        anchors {
            left: parent.left
            top: parent.top
            leftMargin: menu.__contentsMargins
            verticalCenter: parent.verticalCenter
        }

        Icon {
            id: statusIcon
            color: Theme.palette.selected.backgroundText
            keyColor: "#cccccc"

            width: height
            height: Math.min(units.gu(5), parent.height - units.gu(1))
        }

        Icon {
            id: iconConnectivity
            color: Theme.palette.selected.backgroundText
            keyColor: "#cccccc"

            width: height
            height: Math.min(units.gu(5), parent.height - units.gu(1))
        }
    }

    Column {
        id: columnStatus
        anchors {
            left: iconRow.right
            leftMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
            rightMargin: menu.__contentsMargins
        }

        Label {
            id: labelStatus

            elide: Text.ElideRight
        }

        Label {
            id: labelSimIdentifier

            elide: Text.ElideRight
            visible: text !== ""

            fontSize: "x-small"
            font.bold: true
        }
    }

    Item {
        height: parent.height

        anchors {
            right: parent.right
            rightMargin: menu.__contentsMargins
            verticalCenter: parent.verticalCenter
        }

        RoamingIndication {
            id: roamingIndication
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            visible: menu.roaming
            height: Math.min(units.gu(5), parent.height - units.gu(1))
        }

        Button {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            id: buttonUnlock
            objectName: "buttonUnlockSim"
            visible: menu.locked

            text: i18n.tr("Unlock")

            height: Math.min(units.gu(4), parent.height - units.gu(1))
            onTriggered: menu.unlock()
        }
    }
}
