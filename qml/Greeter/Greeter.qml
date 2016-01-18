/*
 * Copyright (C) 2013,2014,2015 Canonical, Ltd.
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
import GSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.SystemImage 0.1
import Unity.Launcher 0.1
import "../Components"

Showable {
    id: root
    created: loader.status == Loader.Ready

    property real dragHandleLeftMargin: 0

    property url background

    // How far to offset the top greeter layer during a launcher left-drag
    property real launcherOffset

    readonly property bool active: required || hasLockedApp
    readonly property bool fullyShown: loader.item ? loader.item.fullyShown : false

    // True when the greeter is waiting for PAM or other setup process
    readonly property alias waiting: d.waiting

    property string lockedApp: ""
    readonly property bool hasLockedApp: lockedApp !== ""

    property bool forcedUnlock
    readonly property bool locked: lightDM.greeter.active && !lightDM.greeter.authenticated && !forcedUnlock

    property bool tabletMode
    property url viewSource // only used for testing

    property int maxFailedLogins: -1 // disabled by default for now, will enable via settings in future
    property int failedLoginsDelayAttempts: 7 // number of failed logins
    property real failedLoginsDelayMinutes: 5 // minutes of forced waiting

    readonly property bool animating: loader.item ? loader.item.animating : false

    signal tease()
    signal sessionStarted()
    signal emergencyCall()

    function forceShow() {
        showNow();
        loader.item.reset();
    }

    function notifyAppFocused(appId) {
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
        } else if (appId !== "unity8-dash") { // dash isn't started by user
            d.startUnlock(false /* toTheRight */);
        }
    }

    function notifyAboutToFocusApp(appId) {
        if (!active) {
            return;
        }

        // A hint that we're about to focus an app.  This way we can look
        // a little more responsive, rather than waiting for the above
        // notifyAppFocused call.  We also need this in case we have a locked
        // app, in order to show lockscreen instead of new app.
        d.startUnlock(false /* toTheRight */);
    }

    // This is a just a glorified notifyAboutToFocusApp(), but it does one
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

    LightDM{id:lightDM} // Provide backend access
    QtObject {
        id: d

        readonly property bool multiUser: lightDM.users.count > 1
        property int currentIndex
        property bool waiting

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

        function selectUser(uid, reset) {
            d.waiting = true;
            if (reset) {
                loader.item.reset();
            }
            currentIndex = uid;
            var user = lightDM.users.data(uid, lightDM.userRoles.NameRole);
            AccountsService.user = user;
            LauncherModel.setUser(user);
            lightDM.greeter.authenticate(user); // always resets auth state
        }

        function login() {
            enabled = false;
            if (lightDM.greeter.startSessionSync()) {
                sessionStarted();
                if (loader.item) {
                    loader.item.notifyAuthenticationSucceeded();
                }
            } else if (loader.item) {
                loader.item.notifyAuthenticationFailed();
            }
            enabled = true;
        }

        function startUnlock(toTheRight) {
            if (loader.item) {
                return loader.item.tryToUnlock(toTheRight);
            } else {
                return false;
            }
        }

        function checkForcedUnlock() {
            if (forcedUnlock && shown && loader.item) {
                // pretend we were just authenticated
                loader.item.notifyAuthenticationSucceeded();
                loader.item.hide();
            }
        }
    }

    onLauncherOffsetChanged: {
        if (launcherOffset > 0) {
            d.lastKnownPositiveOffset = launcherOffset;
        }
    }

    onForcedUnlockChanged: d.checkForcedUnlock()
    Component.onCompleted: d.checkForcedUnlock()

    onRequiredChanged: {
        if (required) {
            d.waiting = true;
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
            root.forceActiveFocus();
            d.selectUser(d.currentIndex, true);
            lightDM.infographic.readyForDataChange();
        }

        Connections {
            target: loader.item
            onSelected: {
                d.selectUser(index, true);
            }
            onResponded: {
                if (root.locked) {
                    lightDM.greeter.respond(response);
                } else {
                    if (lightDM.greeter.active && !lightDM.greeter.authenticated) { // could happen if forcedUnlock
                        d.login();
                    }
                    loader.item.hide();
                }
            }
            onTease: root.tease()
            onEmergencyCall: root.emergencyCall()
            onRequiredChanged: {
                if (!loader.item.required) {
                    root.hide();
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
            property: "locked"
            value: root.locked
        }

        Binding {
            target: loader.item
            property: "alphanumeric"
            value: AccountsService.passwordDisplayHint === AccountsService.Keyboard
        }

        Binding {
            target: loader.item
            property: "currentIndex"
            value: d.currentIndex
        }

        Binding {
            target: loader.item
            property: "userModel"
            value: lightDM.users
        }

        Binding {
            target: loader.item
            property: "infographicModel"
            value: lightDM.infographic
        }
    }

    Connections {
        target: lightDM.greeter

        onShowGreeter: root.forceShow()

        onHideGreeter: {
            d.login();
            loader.item.hide();
        }

        onShowMessage: {
            if (!lightDM.greeter.active) {
                return; // could happen if hideGreeter() comes in before we prompt
            }

            // inefficient, but we only rarely deal with messages
            var html = text.replace(/&/g, "&amp;")
                           .replace(/</g, "&lt;")
                           .replace(/>/g, "&gt;")
                           .replace(/\n/g, "<br>");
            if (isError) {
                html = "<font color=\"#df382c\">" + html + "</font>";
            }

            loader.item.showMessage(html);
        }

        onShowPrompt: {
            d.waiting = false;

            if (!lightDM.greeter.active) {
                return; // could happen if hideGreeter() comes in before we prompt
            }

            loader.item.showPrompt(text, isSecret, isDefaultPrompt);
        }

        onAuthenticationComplete: {
            d.waiting = false;

            if (lightDM.greeter.authenticated) {
                AccountsService.failedLogins = 0;
                d.login();
                if (!lightDM.greeter.promptless) {
                    loader.item.hide();
                }
            } else {
                if (!lightDM.greeter.promptless) {
                    AccountsService.failedLogins++;
                }

                // Check if we should initiate a factory reset
                if (maxFailedLogins >= 2) { // require at least a warning
                    if (AccountsService.failedLogins === maxFailedLogins - 1) {
                        loader.item.showLastChance();
                    } else if (AccountsService.failedLogins >= maxFailedLogins) {
                        SystemImage.factoryReset(); // Ouch!
                    }
                }

                // Check if we should initiate a forced login delay
                if (failedLoginsDelayAttempts > 0
                        && AccountsService.failedLogins > 0
                        && AccountsService.failedLogins % failedLoginsDelayAttempts == 0) {
                    forcedDelayTimer.forceDelay();
                }

                loader.item.notifyAuthenticationFailed();
                if (!lightDM.greeter.promptless) {
                    d.selectUser(d.currentIndex, false);
                }
            }
        }

        onRequestAuthenticationUser: {
            // Find index for requested user, if it exists
            for (var i = 0; i < lightDM.users.count; i++) {
                if (user === lightDM.users.data(i, lightDM.userRoles.NameRole)) {
                    d.selectUser(i, true);
                    return;
                }
            }
        }
    }

    Binding {
        target: lightDM.greeter
        property: "active"
        value: root.active
    }

    Binding {
        target: lightDM.infographic
        property: "username"
        value: AccountsService.statsWelcomeScreen ? lightDM.users.data(d.currentIndex, lightDM.userRoles.NameRole) : ""
    }

    Connections {
        target: i18n
        onLanguageChanged: lightDM.infographic.readyForDataChange()
    }
}
