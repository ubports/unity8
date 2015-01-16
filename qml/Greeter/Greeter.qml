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
import Unity.Launcher 0.1
import "../Components"

Showable {
    id: root
    created: loader.status == Loader.Ready

    property real dragHandleLeftMargin: 0

    property url background

    // How far to offset the top greeter layer during a launcher left-drag
    property real launcherOffset

    readonly property bool active: shown || hasLockedApp
    readonly property bool fullyShown: loader.item ? loader.item.fullyShown : false

    // True when the greeter is waiting for PAM or other setup process
    readonly property alias waiting: d.waiting

    property string lockedApp: ""
    readonly property bool hasLockedApp: lockedApp !== ""

    property bool forcedUnlock
    readonly property bool locked: LightDM.Greeter.active && !LightDM.Greeter.authenticated && !forcedUnlock

    property bool tabletMode

    property int maxFailedLogins: -1 // disabled by default for now, will enable via settings in future
    property int failedLoginsDelayAttempts: 7 // number of failed logins
    property int failedLoginsDelayMinutes: 5 // minutes of forced waiting

    signal tease()
    signal sessionStarted()
    signal emergencyCall()

    function notifyAppFocused(appId) {
        if (!active) {
            return;
        }

        if (hasLockedApp) {
            if (appId === lockedApp) {
                hide(); // show locked app
            } else {
                show();
                d.startUnlock(false);
            }
        } else if (appId !== "unity8-dash") { // dash isn't started by user
            d.startUnlock(false);
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
        d.startUnlock(false);
    }

    function notifyShowingDashFromDrag() {
        if (!active) {
            return;
        }

        // This is a just a glorified notifyAboutToFocusApp(), but it does one
        // other thing: it hides any cover pages to the RIGHT, because the user
        // just came from a launcher drag starting on the left.
        d.startUnlock(true);
    }

    QtObject {
        id: d

        readonly property bool multiUser: LightDM.Users.count > 1
        property int currentIndex
        property int delayMinutes
        property bool waiting

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
            enabled: !d.launcherOffsetValid
            StandardAnimation {}
        }

        function selectUser(uid) {
            currentIndex = uid;
            var user = LightDM.Users.data(uid, LightDM.UserRoles.NameRole);
            AccountsService.user = user;
            LauncherModel.setUser(user);
            LightDM.Greeter.authenticate(user); // always resets auth state
        }

        function login() {
            enabled = false;
            if (LightDM.Greeter.startSessionSync()) {
                sessionStarted();
                loader.item.authenticated(true);
            } else {
                loader.item.authenticated(false);
            }
            enabled = true;
        }

        function startUnlock(toTheRight) {
            if (loader.item) {
                loader.item.tryToUnlock(toTheRight);
            }
        }
    }

    onForcedUnlockChanged: {
        if (forcedUnlock && shown) {
            // pretend we were just authenticated
            loader.item.authenticated(true);
        }
    }

    onRequiredChanged: {
        if (required) {
            d.waiting = true;
            lockedApp = "";
        }
    }

    Timer {
        id: forcedDelayTimer
        interval: 1000 * 60
        onTriggered: {
            if (d.delayMinutes > 0) {
                d.delayMinutes -= 1;
                if (d.delayMinutes > 0) {
                    start(); // go again
                }
            }
        }
    }

    // event eater
    // Nothing should leak to items behind the greeter
    MouseArea { anchors.fill: parent }

    Loader {
        id: loader
        objectName: "loader"

        anchors.fill: parent

        active: root.required
        source: (d.multiUser || tabletMode) ? "WideView.qml" : "NarrowView.qml"

        onLoaded: {
            loader.item.reset();
            root.lockedApp = "";
            root.forceActiveFocus();
            d.selectUser(d.currentIndex);
            LightDM.InfoGraphic.readyForDataChange();
        }

        Connections {
            target: loader.item
            onSelected: {
                d.selectUser(index);
            }
            onResponded: {
                if (root.locked) {
                    LightDM.Greeter.respond(response);
                } else {
                    d.login();
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
            value: d.delayMinutes
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
            property: "currentUser"
            value: LightDM.Users.data(d.currentIndex, LightDM.UserRoles.NameRole)
        }

        Binding {
            target: loader.item
            property: "userModel"
            value: LightDM.Users
        }

        Binding {
            target: loader.item
            property: "infographicModel"
            value: LightDM.Infographic
        }
    }

    Connections {
        target: LightDM.Greeter

        onShowGreeter: {
            root.show();
            loader.item.reset();
            d.selectUser(d.currentIndex);
        }

        onHideGreeter: {
            d.login();
            loader.item.hide();
        }

        onShowMessage: {
            if (!LightDM.Greeter.active) {
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

            if (!LightDM.Greeter.active) {
                return; // could happen if hideGreeter() comes in before we prompt
            }

            loader.item.showPrompt(text, isSecret, isDefaultPrompt);
        }

        onAuthenticationComplete: {
            d.waiting = false;

            if (LightDM.Greeter.authenticated) {
                AccountsService.failedLogins = 0;
                d.login();
                if (!LightDM.Greeter.promptless) {
                    loader.item.hide();
                }
            } else {
                if (!LightDM.Greeter.promptless) {
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
                if (failedLoginsDelayAttempts > 0 && AccountsService.failedLogins % failedLoginsDelayAttempts == 0) {
                    d.delayMinutes = failedLoginsDelayMinutes;
                    forcedDelayTimer.start();
                }

                loader.item.authenticated(false);
                if (!LightDM.Greeter.promptless) {
                    d.selectUser(d.currentIndex);
                }
            }
        }

        onRequestAuthenticationUser: {
            // Find index for requested user, if it exists
            for (var i = 0; i < LightDM.Users.count; i++) {
                if (user === LightDM.Users.data(i, LightDM.UserRoles.NameRole)) {
                    d.selectUser(i);
                    return;
                }
            }
        }
    }

    Binding {
        target: LightDM.Greeter
        property: "active"
        value: root.active
    }

    Binding {
        target: LightDM.Infographic
        property: "username"
        value: AccountsService.statsWelcomeScreen ? LightDM.Users.data(d.currentIndex, LightDM.UserRoles.NameRole) : ""
    }

    Connections {
        target: i18n
        onLanguageChanged: LightDM.Infographic.readyForDataChange()
    }
}
