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

import QtQuick 2.3
import AccountsService 0.1
import LightDM 0.1 as LightDM
import Ubuntu.Components 1.1
import "../Components"

Item {
    id: root

    property alias launcherOffset: coverPage.launcherOffset
    property int currentIndex // unused
    property alias delayMinutes: lockscreen.delayMinutes
    property alias backgroundTopMargin: coverPage.backgroundTopMargin
    property bool fullyShown: coverPage.showProgress === 1 || lockscreen.shown
    property bool required: coverPage.required || lockscreen.required

    signal selected(int index)
    signal unlocked()
    signal tease()

    function showMessage(html) {
        // TODO
    }

    function showPrompt(text, isSecret, isDefaultPrompt) {
        lockscreen.promptText = isDefaultPrompt ? "" : text.toLowerCase();
        lockscreen.maybeShow();
    }

    function showLastChance() {
        var title = lockscreen.alphaNumeric ?
                    i18n.tr("Sorry, incorrect passphrase.") :
                    i18n.tr("Sorry, incorrect passcode.");
        var text = i18n.tr("This will be your last attempt.") + " " +
                   (lockscreen.alphaNumeric ?
                    i18n.tr("If passphrase is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted.") :
                    i18n.tr("If passcode is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted."));
        lockscreen.showInfoPopup(title, text);
    }

    function hide() {
        lockscreen.hide();
        coverPage.hide();
    }

    function authenticated(success) {
        if (success) {
            lockscreen.hide();
        } else {
            lockscreen.clear(true);
        }
    }

    function reset() {
        coverPage.show();
    }

    function tryToUnlock(toTheRight) {
        if (!LightDM.Greeter.authenticated) {
            lockscreen.maybeShow();
        }
        if (toTheRight) {
            coverPage.hideRight();
        } else {
            coverPage.hide();
        }
    }

    QtObject {
        id: d
    }

    Lockscreen {
        id: lockscreen
        objectName: "lockscreen"

        shown: false
        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }
        anchors.fill: parent
        visible: required
        background: greeter.background
        darkenBackground: 0.4
        alphaNumeric: AccountsService.passwordDisplayHint === AccountsService.Keyboard
        minPinLength: 4
        maxPinLength: 4

        property string promptText
        infoText: promptText !== "" ? i18n.tr("Enter %1").arg(promptText) :
                  alphaNumeric ? i18n.tr("Enter passphrase") :
                                 i18n.tr("Enter passcode")
        errorText: promptText !== "" ? i18n.tr("Sorry, incorrect %1").arg(promptText) :
                   alphaNumeric ? i18n.tr("Sorry, incorrect passphrase") + "\n" +
                                  i18n.tr("Please re-enter") :
                                  i18n.tr("Sorry, incorrect passcode")

        // FIXME: We *should* show emergency dialer if there is a SIM present,
        // regardless of whether the side stage is enabled.  But right now,
        // the assumption is that narrow screens are phones which have SIMs
        // and wider screens are tablets which don't.  When we do allow this
        // on devices with a side stage and a SIM, work should be done to
        // ensure that the main stage is disabled while the dialer is present
        // in the side stage.  See the FIXME in the stage loader in Shell.qml.
        showEmergencyCallButton: !greeter.tabletMode

        onEntered: LightDM.Greeter.respond(passphrase)
        onCancel: coverPage.show()
        onEmergencyCall: greeter.emergencyCall()

        function maybeShow() {
            if (!greeter.forcedUnlock) {
                show();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: coverPage.showProgress * 0.8
    }

    CoverPage {
        id: coverPage
        objectName: "coverPage"
        height: parent.height
        width: parent.width
        background: greeter.background
        onTease: root.tease()

        onShowProgressChanged: {
            if (showProgress === 1) {
                lockscreen.reset();
            }

            if (showProgress === 0) {
                if (greeter.locked) {
                    lockscreen.clear(false); // to reset focus if necessary
                } else {
                    root.unlocked();
                }
            }
        }

        Clock {
            anchors {
                top: parent.top
                topMargin: units.gu(2)
                horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
