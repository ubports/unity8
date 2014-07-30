/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0

Dialog {
    id: factoryResetDialog

    property bool alphaNumeric: false

    text: alphaNumeric ?
          i18n.tr("Sorry, incorrect passphrase.") :
          i18n.tr("Sorry, incorrect passcode.")

    Label {
        text: i18n.tr("This will be your last attempt.")
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        text: alphaNumeric ?
              i18n.tr("If passphrase is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted.") :
              i18n.tr("If passcode is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted.")
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    Button {
        id: button
        objectName: "button"
        text: i18n.tr("OK")
        onClicked: PopupUtils.close(factoryResetDialog)
        color: UbuntuColors.green
    }
}
