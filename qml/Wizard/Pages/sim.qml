/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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

import QtQuick 2.4
import MeeGo.QOfono 0.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Unity.Session 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "simPage"

    title: i18n.tr("No SIM card installed")
    forwardButtonSourceComponent: forwardButton
    customTitle: true
    hasBackButton: false

    property bool hadSIM: simManager0.present || simManager1.present

    Timer {
        id: timer
        interval: 250
        running: true
        onTriggered: {
            print("=== SIM page: timer triggered");
            hadSIM = simManager0.present || simManager1.present;
            print("=== SIM page: had sim:", hadSIM);
        }
    }

    Connections {
        target: modemManager
        onGotSimCardChanged: {
            print("=== SIM page: SIM card inserted");
            if (!hadSIM && modemManager.gotSimCard) { // show the restart dialog in case a SIM gets inserted
                print("=== SIM page: showing reboot dialog");
                restartDialog.visible = true;
            }
        }
    }

    Dialog {
        id: restartDialog
        title: i18n.tr("SIM card added")
        text: i18n.tr("You must restart the device to access the mobile network.")

        Button {
            id: restartButton
            text: i18n.tr("Restart")
            onClicked: {
                DBusUnitySessionService.reboot();
            }
        }
    }

    Column {
        anchors {
            fill: content
            leftMargin: leftMargin
            rightMargin: rightMargin
        }
        spacing: units.gu(4)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("You won’t be able to make calls or use text messaging without a SIM.")
            fontSize: "small"
            font.weight: Font.Light
            color: restartDialog.visible ? Theme.palette.normal.backgroundText : textColor
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: i18n.tr("To proceed with no SIM tap Skip.")
            fontSize: "small"
            font.weight: Font.Light
            color: restartDialog.visible ? Theme.palette.normal.backgroundText : textColor
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Skip")
            onClicked: {
                seenSIMPage = true;
                pageStack.next();
            }
        }
    }
}
