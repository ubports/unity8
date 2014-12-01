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
import AccountsService 0.1
import LightDM 0.1 as LightDM
import Ubuntu.Components 1.1
import Ubuntu.SystemImage 0.1
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Launcher 0.1
import "../Components"

Showable {
    id: greeter
    created: greeterContentLoader.status == Loader.Ready && greeterContentLoader.item.ready

    property url background

    // How far to offset the top greeter layer during a launcher left-drag
    property real launcherOffset

    // 1 when fully shown and 0 when fully hidden
    readonly property real showProgress: MathUtils.clamp((width - Math.abs(greeterContentLoader.x)) / width, 0, 1)
    readonly property bool fullyShown: showProgress === 1 || lockscreen.shown

    // True when the greeter is waiting for PAM or other setup process
    property bool waiting: true

    property string lockedApp: ""
    property bool hasLockedApp: lockedApp !== ""

    showAnimation: StandardAnimation { property: "dragOffset"; to: 0; duration: UbuntuAnimation.FastDuration }
    hideAnimation: __leftHideAnimation

    property alias lockscreen: lockscreen

    readonly property bool locked: LightDM.Greeter.active && !LightDM.Greeter.authenticated && !forcedUnlock
    property bool forcedUnlock
    onForcedUnlockChanged: if (forcedUnlock) lockscreen.hide()

    property bool tabletMode
    readonly property bool narrowMode: !multiUser && !tabletMode
    readonly property bool multiUser: LightDM.Users.count > 1

    readonly property int currentIndex: greeterContentLoader.currentIndex

    property var __leftHideAnimation: StandardAnimation { property: "dragOffset"; to: -width }
    property var __rightHideAnimation: StandardAnimation { property: "dragOffset"; to: width }

    property real dragOffset

    // We define a proxy and "is valid" property for launcherOffset because of
    // a quirk in Qml.  We only want this animation to fire if we are reset
    // back to zero (on a release of the drag).  But by defining a Behavior,
    // we delay the property from reaching zero until it's too late.  So we set
    // a proxy bound to launcherOffset, which lets us see the target value of
    // zero as we also slowly adjust the proxy down to zero.  But Qml will send
    // change notifications in declaration order.  So unless we define the
    // proxy first, we need a little "is valid" property defined above the
    // proxy, so we know when to enable the proxy behavior.  Phew!
    readonly property bool launcherOffsetValid: launcherOffset > 0
    property real launcherOffsetProxy: shown ? launcherOffset : 0
    Behavior on launcherOffsetProxy {
        enabled: !launcherOffsetValid
        StandardAnimation {}
    }

    signal tease()
    signal sessionStarted()
    signal emergencyCall()

    function hideRight() {
        if (shown) {
            hideAnimation = __rightHideAnimation
            hide()
        }
    }

    function reset() {
        if (greeterContentLoader.item) {
            greeterContentLoader.item.reset()
        }
    }

    function login() {
        enabled = false;
        if (LightDM.Greeter.startSessionSync()) {
            sessionStarted();
            hide();
            lockscreen.hide();
        }
        enabled = true;
    }

    function notifyAppFocused(appId) {
        if (narrowMode) {
            if (appId === "dialer-app" && callManager.hasCalls && locked) {
                // If we are in the middle of a call, make dialer lockedApp and show it.
                // This can happen if user backs out of dialer back to greeter, then
                // launches dialer again.
                lockedApp = appId;
            }
            if (hasLockedApp) {
                if (appId === lockedApp) {
                    lockscreen.hide(); // show locked app
                } else {
                    startUnlock(); // show lockscreen if necessary
                }
            }
            hide();
        } else {
            if (LightDM.Greeter.active) {
                startUnlock();
            }
        }
    }

    // Do we need these next two functions, really?
    function notifyFocusChanged(appId) {
        if (hasLockedApp && lockedApp !== appId) {
            startUnlock();
        }
    }

    function notifyAppAdded(appId) {
        if (shown && appId != "unity8-dash") {
            startUnlock();
        }
        if (narrowMode && hasLockedApp && appId === lockedApp) {
            lockscreen.hide(); // show locked app
        }
    }

    function notifyAboutToStartApp(appId) {
        if (hasLockedApp) {
            startUnlock();
        }
    }

    function startUnlock() {
        if (narrowMode) {
            if (!LightDM.Greeter.authenticated) {
                lockscreen.maybeShow();
            }
            hide();
        } else {
            show();
            if (greeterContentLoader.item) {
                greeterContentLoader.item.tryToUnlock();
            }
        }
    }

    onRequiredChanged: {
        // Reset hide animation to default once we're finished with it
        if (required) {
            // Reset hide animation so that a hide() call is reliably left
            hideAnimation = __leftHideAnimation
        }
    }

    onShownChanged: {
        if (shown) {
            waiting = true;

            if (narrowMode) {
                LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
            } else {
                reset();
            }
            lockedApp = "";
            forceActiveFocus();
        }
    }

    onFullyShownChanged: {
        // Wait until the greeter is completely covering lockscreen before resetting it.
        if (narrowMode && fullyShown && !LightDM.Greeter.authenticated) {
            lockscreen.reset();
            lockscreen.maybeShow();
        }
    }

    onShowProgressChanged: {
        if (showProgress === 0) {
            if ((LightDM.Greeter.promptless && LightDM.Greeter.authenticated) || forcedUnlock) {
                greeter.login();
            } else if (narrowMode) {
                lockscreen.clear(false); // to reset focus if necessary
            }
        }
    }

    QtObject {
        id: d

        function selectUser(uid) {
            // Update launcher items for new user
            var user = LightDM.Users.data(uid, LightDM.UserRoles.NameRole);
            AccountsService.user = user;
            LauncherModel.setUser(user);
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

        onEntered: LightDM.Greeter.respond(passphrase);
        onCancel: greeter.show()
        onEmergencyCall: greeter.emergencyCall()

        onShownChanged: if (shown) greeter.lockedApp = ""

        function maybeShow() {
            if (!greeter.forcedUnlock) {
                show();
            }
        }

        Timer {
            id: forcedDelayTimer
            interval: 1000 * 60
            onTriggered: {
                if (lockscreen.delayMinutes > 0) {
                    lockscreen.delayMinutes -= 1
                    if (lockscreen.delayMinutes > 0) {
                        start() // go again
                    }
                }
            }
        }

        Component.onCompleted: {
            if (greeter.narrowMode) {
                LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: greeter.showProgress * 0.8
    }

    Loader {
        id: greeterContentLoader
        objectName: "greeterContentLoader"

        x: launcherOffsetProxy + dragOffset
        width: parent.width
        height: parent.height

        property var model: LightDM.Users
        property int currentIndex: 0
        property var infographicModel: LightDM.Infographic
        readonly property int backgroundTopMargin: -greeter.y

        source: (greeter.required || lockscreen.required) ? "GreeterContent.qml" : ""

        onLoaded: {
            d.selectUser(currentIndex);
        }

        Connections {
            target: greeterContentLoader.item

            onSelected: {
                d.selectUser(uid);
                greeterContentLoader.currentIndex = uid;
            }
            onUnlocked: greeter.hide()
            onTease: greeter.tease()
        }
    }

    Connections {
        target: LightDM.Greeter

        onShowGreeter: greeter.show()
        onHideGreeter: greeter.login()

        onShowPrompt: {
            waiting = false;

            if (!LightDM.Greeter.active) {
                return; // could happen if hideGreeter() comes in before we prompt
            }

            if (greeter.narrowMode) {
                lockscreen.promptText = isDefaultPrompt ? "" : text.toLowerCase();
                lockscreen.maybeShow();
            }
        }

        onPromptlessChanged: {
            if (!LightDM.Greeter.active) {
                return; // could happen if hideGreeter() comes in before we prompt
            }
            if (greeter.narrowMode) {
                if (LightDM.Greeter.promptless && LightDM.Greeter.authenticated) {
                    lockscreen.hide()
                } else {
                    lockscreen.reset();
                    lockscreen.maybeShow();
                }
            }
        }

        onAuthenticationComplete: {
            waiting = false;
            if (LightDM.Greeter.authenticated) {
                AccountsService.failedLogins = 0
            }
            // Else only penalize user for a failed login if they actually were
            // prompted for a password.  We do this below after the promptless
            // early exit.

            if (LightDM.Greeter.promptless) {
                return;
            }

            if (LightDM.Greeter.authenticated) {
                greeter.login();
            } else {
                AccountsService.failedLogins++
                if (maxFailedLogins >= 2) { // require at least a warning
                    if (AccountsService.failedLogins === maxFailedLogins - 1) {
                        var title = lockscreen.alphaNumeric ?
                                    i18n.tr("Sorry, incorrect passphrase.") :
                                    i18n.tr("Sorry, incorrect passcode.")
                        var text = i18n.tr("This will be your last attempt.") + " " +
                                   (lockscreen.alphaNumeric ?
                                    i18n.tr("If passphrase is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted.") :
                                    i18n.tr("If passcode is entered incorrectly, your phone will conduct a factory reset and all personal data will be deleted."))
                        lockscreen.showInfoPopup(title, text)
                    } else if (AccountsService.failedLogins >= maxFailedLogins) {
                        SystemImage.factoryReset() // Ouch!
                    }
                }
                if (failedLoginsDelayAttempts > 0 && AccountsService.failedLogins % failedLoginsDelayAttempts == 0) {
                    lockscreen.delayMinutes = failedLoginsDelayMinutes
                    forcedDelayTimer.start()
                }

                lockscreen.clear(true);
                if (greeter.narrowMode) {
                    LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
                }
            }
        }
    }

    Binding {
        target: LightDM.Greeter
        property: "active"
        value: greeter.shown || lockscreen.shown || greeter.hasLockedApp
    }
}
