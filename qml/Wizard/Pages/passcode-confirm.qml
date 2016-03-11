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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.SecurityPrivacy 1.0
import ".." as LocalComponents
import "../../Components" as UnityComponents

/**
 * See the main passwd-type page for an explanation of why we don't actually
 * directly set the password here.
 */

LocalComponents.Page {
    id: passcodeConfirmPage
    objectName: "passcodeConfirmPage"
    customTitle: true
    backButtonText: i18n.tr("Cancel")

    // If we are entering this page, clear any saved password and get focus
    onEnabledChanged: if (enabled) lockscreen.clear(false)

    UnityComponents.Lockscreen {
        id: lockscreen
        anchors {
            fill: content
        }

        infoText: i18n.tr("Confirm passcode")

        errorText: i18n.tr("Incorrect passcode.") + "\n" + i18n.ctr("Enter the passcode again", "Please re-enter.")

        foregroundColor: textColor

        showEmergencyCallButton: false
        showCancelButton: false
        alphaNumeric: false
        minPinLength: 4
        maxPinLength: 4

        onEntered: {
            if (passphrase === root.password) {
                confirmTimer.start();
            } else {
                clear(true);
            }
        }

        Timer {
            id: confirmTimer
            interval: UbuntuAnimation.SnapDuration
            onTriggered: pageStack.next()
        }
    }
}
