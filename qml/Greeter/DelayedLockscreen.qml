/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import Ubuntu.Components 1.3

Item {
    id: root

    property int delayMinutes
    property bool alphaNumeric

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: units.gu(4)
        anchors.rightMargin: units.gu(4)
        anchors.verticalCenter: parent.verticalCenter
        spacing: units.gu(2)

        Label {
            id: deviceLockedLabel
            objectName: "deviceLockedLabel"
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSize: "x-large"
            color: "white"
            text: i18n.tr("Device Locked")
        }

        Item { // spacer
            width: units.gu(1)
            height: units.gu(1)
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: "white"
            text: alphaNumeric ?
                  i18n.tr("You have been locked out due to too many failed passphrase attempts.") :
                  i18n.tr("You have been locked out due to too many failed passcode attempts.")
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: "white"
            text: i18n.tr("Please wait %1 minute and then try again…",
                          "Please wait %1 minutes and then try again…",
                          root.delayMinutes).arg(root.delayMinutes)
        }

        Item { // spacer
            width: units.gu(1)
            height: units.gu(1)
        }

        Icon {
            name: "lock"
            color: "white"
            height: units.gu(4)
            width: units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
