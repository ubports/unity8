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
import QtQuick.Window 2.2
import Ubuntu.Components 1.3
import Ubuntu.Telephony 0.1 as Telephony
import "../Components"

FocusScope {
    id: root

    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property alias launcherOffset: coverPage.launcherOffset
    property alias currentIndex: loginList.currentIndex
    property alias delayMinutes: delayedLockscreen.delayMinutes
    property alias backgroundTopMargin: coverPage.backgroundTopMargin
    property url background
    property bool hasCustomBackground
    property bool locked
    property alias alphanumeric: loginList.alphanumeric
    property alias userModel: loginList.model
    property alias infographicModel: coverPage.infographicModel
    property string sessionToStart
    property bool waiting
    readonly property bool fullyShown: coverPage.showProgress === 1 || lockscreen.shown
    readonly property bool required: coverPage.required || lockscreen.required
    readonly property bool animating: coverPage.showAnimation.running || coverPage.hideAnimation.running

    // so that it can be replaced in tests with a mock object
    property var inputMethod: Qt.inputMethod

    signal selected(int index)
    signal responded(string response)
    signal tease()
    signal emergencyCall()

    function showMessage(html) {
        loginList.showMessage(html);
    }

    function showPrompt(text, isSecret, isDefaultPrompt) {
        loginList.showPrompt(text, isSecret, isDefaultPrompt);
    }

    function showLastChance() {
        /* TODO: when we finish support for resetting device after too many
                 failed logins, we should re-add this popup.
        var title = lockscreen.alphaNumeric ?
                    i18n.tr("Sorry, incorrect passphrase.") :
                    i18n.tr("Sorry, incorrect passcode.");
        var text = i18n.tr("This will be your last attempt.") + " " +
                   (lockscreen.alphaNumeric ?
                    i18n.tr("If passphrase is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted.") :
                    i18n.tr("If passcode is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted."));
        lockscreen.showInfoPopup(title, text);
        */
    }

    function hide() {
        lockscreen.hide();
        coverPage.hide();
    }

    function notifyAuthenticationSucceeded(showFakePassword) {
        if (showFakePassword) {
            loginList.showFakePassword();
        }
    }

    function notifyAuthenticationFailed() {
        loginList.showError();
    }

    function showErrorMessage(msg) {
        coverPage.showErrorMessage(msg);
    }

    function reset(forceShow) {
        loginList.reset();
        if (forceShow) {
            coverPage.show();
        }
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

    Showable {
        id: lockscreen
        objectName: "lockscreen"
        anchors.fill: parent
        shown: false

        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }

        Wallpaper {
            id: lockscreenBackground
            objectName: "lockscreenBackground"
            anchors {
                fill: parent
                topMargin: root.backgroundTopMargin
            }
            source: root.background
        }

        // Darken background to match CoverPage
        Rectangle {
            objectName: "lockscreenShade"
            anchors.fill: parent
            color: "black"
            opacity: root.hasCustomBackground ? 0.4 : 0
        }

        LoginList {
            id: loginList
            objectName: "loginList"

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(40)
            boxVerticalOffset: units.gu(14)
            enabled: !coverPage.shown && visible
            visible: !delayedLockscreen.visible

            locked: root.locked

            onSelected: if (enabled) root.selected(index)
            onResponded: root.responded(response)
        }

        DelayedLockscreen {
            id: delayedLockscreen
            objectName: "delayedLockscreen"
            anchors.fill: parent
            visible: delayMinutes > 0
            alphaNumeric: loginList.alphanumeric
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
        hasCustomBackground: root.hasCustomBackground
        draggable: !root.waiting
        onTease: root.tease()
        onClicked: hide()

        onShowProgressChanged: {
            if (showProgress === 1) {
                loginList.reset();
            } else if (showProgress === 0) {
                loginList.tryToUnlock();
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

    StyledItem {
        id: bottomBar
        visible: lockscreen.shown
        height: units.gu(4)

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.bottom
        anchors.topMargin: - height * (1 - coverPage.showProgress)
                           - (inputMethod && inputMethod.visible ?
                              inputMethod.keyboardRectangle.height : 0)

        Rectangle {
            color: UbuntuColors.porcelain // matches OSK background
            anchors.fill: parent
        }

        Label {
            text: i18n.tr("Cancel")
            anchors.left: parent.left
            anchors.leftMargin: units.gu(2)
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Light
            fontSize: "small"
            color: UbuntuColors.slate

            AbstractButton {
                anchors.fill: parent
                anchors.leftMargin: -units.gu(2)
                anchors.rightMargin: -units.gu(2)
                onClicked: coverPage.show()
            }
        }

        Label {
            objectName: "emergencyCallLabel"
            text: callManager.hasCalls ? i18n.tr("Return to Call") : i18n.tr("Emergency")
            anchors.right: parent.right
            anchors.rightMargin: units.gu(2)
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Light
            fontSize: "small"
            color: UbuntuColors.slate
            // TODO: uncomment once bug 1616538 is fixed
            // visible: telepathyHelper.ready && telepathyHelper.emergencyCallsAvailable
            enabled: visible

            AbstractButton {
                anchors.fill: parent
                anchors.leftMargin: -units.gu(2)
                anchors.rightMargin: -units.gu(2)
                onClicked: root.emergencyCall()
            }
        }
    }

    // FIXME: It's difficult to keep something tied closely to the OSK (bug
    //        1616163).  But as a hack to avoid the background peeking out,
    //        we add an extra Rectangle that just serves to hide the background
    //        during OSK animations.
    Rectangle {
        visible: bottomBar.visible
        height: inputMethod && inputMethod.visible ?
                inputMethod.keyboardRectangle.height : 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: UbuntuColors.porcelain
    }
}
