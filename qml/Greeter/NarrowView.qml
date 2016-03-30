/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import "../Components"

FocusScope {
    id: root

    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property alias launcherOffset: coverPage.launcherOffset
    property int currentIndex // unused
    property alias delayMinutes: lockscreen.delayMinutes
    property alias backgroundTopMargin: coverPage.backgroundTopMargin
    property url background
    property bool locked
    property bool alphanumeric
    property var userModel // unused
    property alias infographicModel: coverPage.infographicModel
    readonly property bool fullyShown: coverPage.showProgress === 1 || lockscreen.shown
    readonly property bool required: coverPage.required || lockscreen.required
    readonly property bool animating: coverPage.showAnimation.running || coverPage.hideAnimation.running

    signal selected(int index) // unused
    signal responded(string response)
    signal tease()
    signal emergencyCall()

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

    function notifyAuthenticationSucceeded() {
        lockscreen.hide();
    }

    function notifyAuthenticationFailed() {
        lockscreen.clear(true);
    }

    function showErrorMessage(msg) {
        coverPage.showErrorMessage(msg);
    }

    function reset() {
        coverPage.show();
    }

    function tryToUnlock(toTheRight) {
        var coverChanged = coverPage.shown;
        lockscreen.maybeShow();
        if (toTheRight) {
            coverPage.hideRight();
        } else {
            coverPage.hide();
        }
        return coverChanged;
    }

    onLockedChanged: {
        if (locked) {
            lockscreen.maybeShow();
        } else {
            lockscreen.hide();
        }
    }

    Lockscreen {
        id: lockscreen
        objectName: "lockscreen"

        shown: false
        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }
        anchors.fill: parent
        visible: required
        enabled: !coverPage.shown
        background: root.background
        darkenBackground: 0.4
        alphaNumeric: root.alphanumeric
        minPinLength: 4
        maxPinLength: 4

        property string promptText
        infoText: promptText !== "" ? i18n.tr("Enter %1").arg(promptText) :
                  alphaNumeric ? i18n.tr("Enter passphrase") :
                                 i18n.tr("Enter passcode")
        errorText: promptText !== "" ? i18n.tr("Sorry, incorrect %1").arg(promptText) :
                   alphaNumeric ? i18n.tr("Sorry, incorrect passphrase") + "\n" +
                                  i18n.ctr("passphrase", "Please re-enter") :
                                  i18n.tr("Sorry, incorrect passcode")

        onEntered: root.responded(passphrase)
        onCancel: coverPage.show()
        onEmergencyCall: root.emergencyCall()

        onEnabledChanged: {
            if (enabled) {
                lockscreen.forceActiveFocus();
            }
        }

        onVisibleChanged: {
            if (visible) {
                lockscreen.forceActiveFocus();
            }
        }

        function maybeShow() {
            if (root.locked && !shown) {
                showNow();
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
        background: root.background
        onTease: root.tease()
        onClicked: hide()

        onShowProgressChanged: {
            if (showProgress === 1) {
                lockscreen.reset();
            }

            if (showProgress === 0) {
                if (root.locked) {
                    lockscreen.clear(false); // to reset focus if necessary
                } else {
                    root.responded("");
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
