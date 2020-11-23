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
import AccountsService 0.1
import Biometryd 0.0
import GSettings 1.0
import Powerd 0.1
import Ubuntu.Components 1.3
import Unity.Launcher 0.1
import Unity.Session 0.1

import "." 0.1
import ".." 0.1
import "../Components"

Showable {
    id: root
    created: loader.status == Loader.Ready

    property real dragHandleLeftMargin: 0

    property url background
    property bool hasCustomBackground

    // How far to offset the top greeter layer during a launcher left-drag
    property real launcherOffset

    readonly property bool active: required || hasLockedApp
    readonly property bool fullyShown: loader.item ? loader.item.fullyShown : false

    property bool allowFingerprint: true

    // True when the greeter is waiting for PAM or other setup process
    readonly property alias waiting: d.waiting

    property string lockedApp: ""
    readonly property bool hasLockedApp: lockedApp !== ""

    property bool forcedUnlock
    readonly property bool locked: LightDMService.greeter.active && !LightDMService.greeter.authenticated && !forcedUnlock

    property bool tabletMode
    property url viewSource // only used for testing

    property int failedLoginsDelayAttempts: 7 // number of failed logins
    property real failedLoginsDelayMinutes: 5 // minutes of forced waiting
    property int failedFingerprintLoginsDisableAttempts: 3 // number of failed fingerprint logins

    readonly property bool animating: loader.item ? loader.item.animating : false

    signal tease()
    signal sessionStarted()
    signal emergencyCall()

    function forceShow() {
        if (!active) {
            d.isLockscreen = true;
        }
        forcedUnlock = false;
        if (required) {
            if (loader.item) {
                loader.item.forceShow();
            }
            // Normally loader.onLoaded will select a user, but if we're
            // already shown, do it manually.
            d.selectUser(d.currentIndex);
        }

        // Even though we may already be shown, we want to call show() for its
        // possible side effects, like hiding indicators and such.
        //
        // We re-check forcedUnlock here, because selectUser above might
        // process events during authentication, and a request to unlock could
        // have come in in the meantime.
        if (!forcedUnlock) {
            showNow();
        }
    }

    function notifyAppFocusRequested(appId) {
        if (!active) {
            return;
        }

        if (hasLockedApp) {
            if (appId === lockedApp) {
                hide(); // show locked app
            } else {
                show();
                d.startUnlock(false /* toTheRight */);
            }
        } else {
            d.startUnlock(false /* toTheRight */);
        }
    }

    // Notify that the user has explicitly requested an app
    function notifyUserRequestedApp() {
        if (!active) {
            return;
        }

        // A hint that we're about to focus an app.  This way we can look
        // a little more responsive, rather than waiting for the above
        // notifyAppFocusRequested call.  We also need this in case we have a locked
        // app, in order to show lockscreen instead of new app.
        d.startUnlock(false /* toTheRight */);
    }

    // This is a just a glorified notifyUserRequestedApp(), but it does one
    // other thing: it hides any cover pages to the RIGHT, because the user
    // just came from a launcher drag starting on the left.
    // It also returns a boolean value, indicating whether there was a visual
    // change or not (the shell only wants to hide the launcher if there was
    // a change).
    function notifyShowingDashFromDrag() {
        if (!active) {
            return false;
        }

        return d.startUnlock(true /* toTheRight */);
    }

    function sessionToStart() {
        for (var i = 0; i < LightDMService.sessions.count; i++) {
            var session = LightDMService.sessions.data(i,
                LightDMService.sessionRoles.KeyRole);
            if (loader.item.sessionToStart === session) {
                return session;
            }
        }

        return LightDMService.greeter.defaultSession;
    }

    QtObject {
        id: d

        readonly property bool multiUser: LightDMService.users.count > 1
        readonly property int selectUserIndex: d.getUserIndex(LightDMService.greeter.selectUser)
        property int currentIndex: Math.max(selectUserIndex, 0)
        readonly property bool waiting: LightDMService.prompts.count == 0 && !root.forcedUnlock
        property bool isLockscreen // true when we are locking an active session, rather than first user login
        readonly property bool secureFingerprint: isLockscreen &&
                                                  AccountsService.failedFingerprintLogins <
                                                  root.failedFingerprintLoginsDisableAttempts
        readonly property bool alphanumeric: AccountsService.passwordDisplayHint === AccountsService.Keyboard

        // We want 'launcherOffset' to animate down to zero.  But not to animate
        // while being dragged.  So ideally we change this only when the user
        // lets go and launcherOffset drops to zero.  But we need to wait for
        // the behavior to be enabled first.  So we cache the last known good
        // launcherOffset value to cover us during that brief gap between
        // release and the behavior turning on.
        property real lastKnownPositiveOffset // set in a launcherOffsetChanged below
        property real launcherOffsetProxy: (shown && !launcherOffsetProxyBehavior.enabled) ? lastKnownPositiveOffset : 0
        Behavior on launcherOffsetProxy {
            id: launcherOffsetProxyBehavior
            enabled: launcherOffset === 0
            UbuntuNumberAnimation {}
        }

        function getUserIndex(username) {
            if (username === "")
                return -1;

            // Find index for requested user, if it exists
            for (var i = 0; i < LightDMService.users.count; i++) {
                if (username === LightDMService.users.data(i, LightDMService.userRoles.NameRole)) {
                    return i;
                }
            }

            return -1;
        }

        function selectUser(index) {
            if (index < 0 || index >= LightDMService.users.count)
                return;
            currentIndex = index;
            var user = LightDMService.users.data(index, LightDMService.userRoles.NameRole);
            AccountsService.user = user;
            LauncherModel.setUser(user);
            LightDMService.greeter.authenticate(user); // always resets auth state
        }

        function hideView() {
            if (loader.item) {
                loader.item.enabled = false; // drop OSK and prevent interaction
                loader.item.hide();
            }
        }

        function login() {
            if (LightDMService.greeter.startSessionSync(root.sessionToStart())) {
                sessionStarted();
                hideView();
            } else if (loader.item) {
                loader.item.notifyAuthenticationFailed();
            }
        }

        function startUnlock(toTheRight) {
            if (loader.item) {
                return loader.item.tryToUnlock(toTheRight);
            } else {
                return false;
            }
        }

        function checkForcedUnlock(hideNow) {
            if (forcedUnlock && shown) {
                hideView();
                if (hideNow) {
                    ShellNotifier.greeter.hide(true); // skip hide animation
                }
            }
        }

        function showFingerprintMessage(msg) {
            d.selectUser(d.currentIndex);
            LightDMService.prompts.prepend(msg, LightDMService.prompts.Error);
            if (loader.item) {
                loader.item.showErrorMessage(msg);
                loader.item.notifyAuthenticationFailed();
            }
        }
    }

    onLauncherOffsetChanged: {
        if (launcherOffset > 0) {
            d.lastKnownPositiveOffset = launcherOffset;
        }
    }

    onForcedUnlockChanged: d.checkForcedUnlock(false /* hideNow */)
    Component.onCompleted: d.checkForcedUnlock(true /* hideNow */)

    onLockedChanged: {
        if (!locked) {
            AccountsService.failedLogins = 0;
            AccountsService.failedFingerprintLogins = 0;

            // Stop delay timer if they logged in with fingerprint
            forcedDelayTimer.stop();
            forcedDelayTimer.delayMinutes = 0;
        }
    }

    onRequiredChanged: {
        if (required) {
            lockedApp = "";
        }
    }

    GSettings {
        id: greeterSettings
        schema.id: "com.canonical.Unity8.Greeter"
    }

    Timer {
        id: forcedDelayTimer

        // We use a short interval and check against the system wall clock
        // because we have to consider the case that the system is suspended
        // for a few minutes.  When we wake up, we want to quickly be correct.
        interval: 500

        property var delayTarget
        property int delayMinutes

        function forceDelay() {
            // Store the beginning time for a lockout in GSettings, so that
            // we still lock the user out if they reboot.  And we store
            // starting time rather than end-time or how-long because:
            // - If storing end-time and on boot we have a problem with NTP,
            //   we might get locked out for a lot longer than we thought.
            // - If storing how-long, and user turns their phone off for an
            //   hour rather than wait, they wouldn't expect to still be locked
            //   out.
            // - A malicious actor could manipulate either of the above
            //   settings to keep the user out longer.  But by storing
            //   start-time, we never make the user wait longer than the full
            //   lock out time.
            greeterSettings.lockedOutTime = new Date().getTime();
            checkForForcedDelay();
        }

        onTriggered: {
            var diff = delayTarget - new Date();
            if (diff > 0) {
                delayMinutes = Math.ceil(diff / 60000);
                start(); // go again
            } else {
                delayMinutes = 0;
            }
        }

        function checkForForcedDelay() {
            if (greeterSettings.lockedOutTime === 0) {
                return;
            }

            var now = new Date();
            delayTarget = new Date(greeterSettings.lockedOutTime + failedLoginsDelayMinutes * 60000);

            // If tooEarly is true, something went very wrong.  Bug or NTP
            // misconfiguration maybe?
            var tooEarly = now.getTime() < greeterSettings.lockedOutTime;
            var tooLate = now >= delayTarget;

            // Compare stored time to system time. If a malicious actor is
            // able to manipulate time to avoid our lockout, they already have
            // enough access to cause damage. So we choose to trust this check.
            if (tooEarly || tooLate) {
                stop();
                delayMinutes = 0;
            } else {
                triggered();
            }
        }

        Component.onCompleted: checkForForcedDelay()
    }

    // event eater
    // Nothing should leak to items behind the greeter
    MouseArea { anchors.fill: parent; hoverEnabled: true }

    Loader {
        id: loader
        objectName: "loader"

        anchors.fill: parent

        active: root.required
        source: root.viewSource.toString() ? root.viewSource :
                (d.multiUser || root.tabletMode) ? "WideView.qml" : "NarrowView.qml"

        onLoaded: {
            root.lockedApp = "";
            item.forceActiveFocus();
            d.selectUser(d.currentIndex);
            LightDMService.infographic.readyForDataChange();
        }

        Connections {
            target: loader.item
            onSelected: {
                d.selectUser(index);
            }
            onResponded: {
                if (root.locked) {
                    LightDMService.greeter.respond(response);
                } else {
                    d.login();
                }
            }
            onTease: root.tease()
            onEmergencyCall: root.emergencyCall()
            onRequiredChanged: {
                if (!loader.item.required) {
                    ShellNotifier.greeter.hide(false);
                }
            }
        }

        Binding {
            target: loader.item
            property: "backgroundTopMargin"
            value: -root.y
        }

        Binding {
            target: loader.item
            property: "launcherOffset"
            value: d.launcherOffsetProxy
        }

        Binding {
            target: loader.item
            property: "dragHandleLeftMargin"
            value: root.dragHandleLeftMargin
        }

        Binding {
            target: loader.item
            property: "delayMinutes"
            value: forcedDelayTimer.delayMinutes
        }

        Binding {
            target: loader.item
            property: "background"
            value: root.background
        }

        Binding {
            target: loader.item
            property: "hasCustomBackground"
            value: root.hasCustomBackground
        }

        Binding {
            target: loader.item
            property: "locked"
            value: root.locked
        }

        Binding {
            target: loader.item
            property: "waiting"
            value: d.waiting
        }

        Binding {
            target: loader.item
            property: "alphanumeric"
            value: d.alphanumeric
        }

        Binding {
            target: loader.item
            property: "currentIndex"
            value: d.currentIndex
        }

        Binding {
            target: loader.item
            property: "userModel"
            value: LightDMService.users
        }

        Binding {
            target: loader.item
            property: "infographicModel"
            value: LightDMService.infographic
        }
    }

    Connections {
        target: LightDMService.greeter

        onShowGreeter: root.forceShow()
        onHideGreeter: root.forcedUnlock = true

        onLoginError: {
            if (!loader.item) {
                return;
            }

            loader.item.notifyAuthenticationFailed();

            if (!automatic) {
                AccountsService.failedLogins++;

                // Check if we should initiate a forced login delay
                if (failedLoginsDelayAttempts > 0
                        && AccountsService.failedLogins > 0
                        && AccountsService.failedLogins % failedLoginsDelayAttempts == 0) {
                    forcedDelayTimer.forceDelay();
                }

                d.selectUser(d.currentIndex);
            }
        }

        onLoginSuccess: {
            if (!automatic) {
                d.login();
            }
        }

        onRequestAuthenticationUser: d.selectUser(d.getUserIndex(user))
    }

    Connections {
        target: ShellNotifier.greeter
        onHide: {
            if (now) {
                root.hideNow(); // skip hide animation
            } else {
                root.hide();
            }
        }
    }

    Binding {
        target: ShellNotifier.greeter
        property: "shown"
        value: root.shown
    }

    Connections {
        target: DBusUnitySessionService
        onLockRequested: root.forceShow()
        onUnlocked: {
            root.forcedUnlock = true;
            ShellNotifier.greeter.hide(true);
        }
    }

    Binding {
        target: LightDMService.greeter
        property: "active"
        value: root.active
    }

    Binding {
        target: LightDMService.infographic
        property: "username"
        value: AccountsService.statsWelcomeScreen ? LightDMService.users.data(d.currentIndex, LightDMService.userRoles.NameRole) : ""
    }

    Connections {
        target: i18n
        onLanguageChanged: LightDMService.infographic.readyForDataChange()
    }

    Observer {
        id: biometryd
        objectName: "biometryd"

        property var operation: null
        readonly property bool idEnabled: root.active &&
                                          root.allowFingerprint &&
                                          Powerd.status === Powerd.On &&
                                          Biometryd.available &&
                                          AccountsService.enableFingerprintIdentification

        function cancelOperation() {
            if (operation) {
                operation.cancel();
                operation = null;
            }
        }

        function restartOperation() {
            cancelOperation();

            if (idEnabled) {
                var identifier = Biometryd.defaultDevice.identifier;
                operation = identifier.identifyUser();
                operation.start(biometryd);
            }
        }

        function failOperation(reason) {
            console.log("Failed to identify user by fingerprint:", reason);
            restartOperation();
            if (!d.secureFingerprint) {
                d.startUnlock(false /* toTheRight */); // use normal login instead
            }
            var msg = d.secureFingerprint ? i18n.tr("Try again") :
                      d.alphanumeric ? i18n.tr("Enter passphrase to unlock") :
                                       i18n.tr("Enter passcode to unlock");
            d.showFingerprintMessage(msg);
        }

        Component.onCompleted: restartOperation()
        Component.onDestruction: cancelOperation()
        onIdEnabledChanged: restartOperation()

        onSucceeded: {
            if (!d.secureFingerprint) {
                failOperation("fingerprint reader is locked");
                return;
            }
            if (result !== LightDMService.users.data(d.currentIndex, LightDMService.userRoles.UidRole)) {
                AccountsService.failedFingerprintLogins++;
                failOperation("not the selected user");
                return;
            }
            console.log("Identified user by fingerprint:", result);
            if (loader.item) {
                loader.item.showFakePassword();
            }
            if (root.active)
                root.forcedUnlock = true;
        }
        onFailed: {
            if (!d.secureFingerprint) {
                failOperation("fingerprint reader is locked");
            } else {
                AccountsService.failedFingerprintLogins++;
                failOperation(reason);
            }
        }
    }
}
