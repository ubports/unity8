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
    id: passwdSetPage
    objectName: "passwdSetPage"
    forwardButtonSourceComponent: forwardButton

    skip: root.passwordMethod === UbuntuSecurityPrivacyPanel.Swipe

    // If we are entering this page, clear any saved password and get focus
    onEnabledChanged: if (enabled) lockscreen.clear(false)

    function confirm() {
        root.password = lockscreen.passphrase;
        confirmTimer.start()
    }

    Timer {
        id: confirmTimer
        interval: UbuntuAnimation.SnapDuration
        onTriggered: pageStack.load(Qt.resolvedUrl("passwd-confirm.qml"));
    }

    UnityComponents.Lockscreen {
        id: lockscreen
        anchors {
            fill: parent
            topMargin: topMargin
            leftMargin: leftMargin
            rightMargin: rightMargin
            bottomMargin: buttonMargin
        }

        infoText: root.passwordMethod === UbuntuSecurityPrivacyPanel.Passphrase ?
                  i18n.tr("Enter passphrase") :
                  i18n.tr("Choose your passcode")

        // Note that the number four comes from PAM settings,
        // which we don't have a good way to interrogate.  We
        // only do this matching instead of PAM because we want
        // to set the password via PAM in a different place
        // than this page.  See comments at top of passwd-type file.
        errorText: i18n.tr("Passphrase must be 4 characters long")

        showEmergencyCallButton: false
        showCancelButton: false
        alphaNumeric: root.passwordMethod === UbuntuSecurityPrivacyPanel.Passphrase
        minPinLength: 4
        maxPinLength: 4

        onEntered: {
            if (passphrase.length >= 4) {
                passwdSetPage.confirm();
            } else {
                lockscreen.clear(true)
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            visible: root.passwordMethod === UbuntuSecurityPrivacyPanel.Passphrase
            enabled: lockscreen.passphrase.length >= 4
            text: i18n.tr("Continue")
            onClicked: passwdSetPage.confirm()
        }
    }
}
