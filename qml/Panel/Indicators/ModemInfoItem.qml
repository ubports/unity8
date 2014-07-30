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
import QtQuick.Layouts 1.1
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Empty {
    id: menu
    implicitHeight:   mainColumn.implicitHeight
                    + mainColumn.anchors.topMargin
                    + mainColumn.anchors.bottomMargin

    property alias statusIcon: statusIcon.name
    property alias statusText: labelStatus.text
    property alias connectivityIcon: iconConnectivity.name
    property alias simIdentifierText: labelSimIdentifier.text
    property bool locked : false
    property bool roaming: false
    signal unlock

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: menu.__contentsMargins
        spacing: units.gu(0.5)

        Label {
            id: labelSimIdentifier
            elide: Text.ElideRight
            visible: text !== ""
            font.bold: true
            opacity: menu.locked ? 0.6 : 1.0
        }

        RowLayout {
            id: statusRow
            spacing: units.gu(1)

            height: labelStatus.height
            width: parent.width

            Label {
                id: labelStatus
                elide: Text.ElideRight
                opacity: 0.6
            }

            RowLayout {
                spacing: 0.5
                height: parent.height
                Icon {
                    id: statusIcon
                    color: Theme.palette.selected.backgroundText

                    width: height
                    height: parent.height

                    visible: name !== ""
                }

                Icon {
                    id: iconConnectivity
                    color: Theme.palette.selected.backgroundText

                    width: height
                    height: parent.height

                    visible: name !== ""
                }
            }

            Item {
                // eat up all the excess space so that RoamingIndication
                // ends up to the far right
                Layout.fillWidth: true
            }

            RoamingIndication {
                id: roamingIndication
                visible: menu.roaming
                height: parent.height
            }
        }

        Button {
            id: buttonUnlock
            objectName: "buttonUnlockSim"
            visible: menu.locked

            text: i18n.tr("Unlock SIM")
            Layout.preferredWidth: implicitWidth + units.gu(5)

            onTriggered: menu.unlock()
        }
    }
}
