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

import QtQuick 2.3
import MeeGo.QOfono 0.2
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "simPage"

    title: i18n.tr("No SIM card installed")
    forwardButtonSourceComponent: forwardButton
    customTitle: true
    hasBackButton: false

    skipValid: !manager.available ||
               (manager.ready && (manager.modems.length < 1 || simManager0.ready)
                              && (manager.modems.length < 2 || simManager1.ready))
    skip: !manager.available || manager.modems.length === 0 || simManager0.present || simManager1.present

    property bool hadModem: false

    Component.onCompleted: {
        hadModem = simManager0.present || simManager1.present
        print("Had modem: " + hadModem)
    }

    Dialog {
        id: restartDialog
        title: i18n.tr("SIM card added")
        text: i18n.tr("You must restart the device to access the mobile network.")

        Button {
            id: restartButton
            text: i18n.tr("Restart")
            onClicked: {
                // TODO reboot for real
                PopupUtils.close(restartDialog)
            }
        }
    }

    OfonoManager {
        id: manager
        property bool ready: false
        onModemsChanged: {
            print("Modems changed " + modems)
            ready = true
            if (!hadModem && (simManager0.present || simManager1.present)) { // show the restart dialog in case a SIM gets inserted
                PopupUtils.open(restartDialog)
            }
        }
    }

    // Ideally we would query the system more cleverly than hardcoding two
    // sims.  But we don't yet have a more clever way.  :(
    OfonoSimManager {
        id: simManager0
        modemPath: manager.modems.length >= 1 ? manager.modems[0] : ""
    }

    OfonoSimManager {
        id: simManager1
        modemPath: manager.modems.length >= 2 ? manager.modems[1] : ""
    }

    Column {
        anchors.fill: content
        spacing: units.gu(4)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("You won’t be able to make calls or use text messaging without a SIM.")
            fontSize: "small"
            font.weight: Font.Light
            color: restartDialog.visible ? Theme.palette.normal.backgroundText : "black"
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: i18n.tr("To proceed with no SIM tap <em>Skip</em>.")
            fontSize: "small"
            font.weight: Font.Light
            color: restartDialog.visible ? Theme.palette.normal.backgroundText : "black"
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Skip")
            onClicked: pageStack.next()
        }
    }
}
