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

import AccountsService 0.1
import GSettings 1.0
import LightDM 0.1 as LightDM
import Powerd 0.1
import QtQuick 2.0
import SessionBroadcast 0.1
import Ubuntu.Components 0.1
import Unity.Application 0.1
import Unity.Launcher 0.1
import "Components"
import "Greeter"
import "Launcher"
import "Panel"
import "Notifications"
import Unity.Notifications 1.0 as NotificationBackend

BasicShell {
    id: shell

    function activateApplication(appId) {
        SessionBroadcast.requestUrlStart(LightDM.Greeter.authenticationUser, appId)
        greeter.hide()
    }

    GSettings {
        id: backgroundSettings
        schema.id: "org.gnome.desktop.background"
    }
    backgroundFallbackSource: backgroundSettings.pictureUri // for ease of customization by system builders
    backgroundSource: AccountsService.backgroundFile

    Lockscreen {
        id: lockscreen
        objectName: "lockscreen"

        hides: [launcher, panel.indicators]
        shown: false
        enabled: true
        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }
        y: panel.panelHeight
        x: required ? 0 : - width
        width: parent.width
        height: parent.height - panel.panelHeight
        pinLength: 4

        onEntered: LightDM.Greeter.respond(passphrase);
        onCancel: greeter.show()

        Component.onCompleted: {
            if (LightDM.Users.count == 1) {
                LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
            }
        }
    }

    Connections {
        target: LightDM.Greeter

        onIdle: {
            greeter.enabled = true
            greeter.showNow()
        }

        onShowPrompt: {
            if (LightDM.Users.count == 1) {
                // TODO: There's no better way for now to determine if its a PIN or a passphrase.
                if (text == "PIN") {
                    lockscreen.alphaNumeric = false
                } else {
                    lockscreen.alphaNumeric = true
                }
                lockscreen.placeholderText = i18n.tr("Please enter %1").arg(text);
                lockscreen.show();
            }
        }

        onAuthenticationComplete: {
            if (LightDM.Greeter.promptless) {
                return;
            }
            if (LightDM.Greeter.authenticated) {
                lockscreen.hide();
            } else {
                lockscreen.clear(true);
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: greeterWrapper.showProgress * 0.8
    }

    Item {
        // Just a tiny wrapper to adjust greeter's x without messing with its own dragging
        id: greeterWrapper
        x: launcher.progress
        width: parent.width
        height: parent.height

        Behavior on x {SmoothedAnimation{velocity: 600}}

        readonly property real showProgress: MathUtils.clamp((1 - x/width) + greeter.showProgress - 1, 0, 1)
        onShowProgressChanged: if (LightDM.Greeter.promptless && showProgress === 0) greeter.login()

        Greeter {
            id: greeter
            objectName: "greeter"

            available: true
            hides: [launcher, panel.indicators]
            shown: true
            background: shell.background

            y: panel.panelHeight
            width: parent.width
            height: parent.height - panel.panelHeight

            dragHandleWidth: shell.edgeSize

            function login() {
                enabled = false;
                LightDM.Greeter.startSessionSync();
            }

            onShownChanged: {
                if (shown) {
                    lockscreen.reset();
                    // If there is only one user, we start authenticating with that one here.
                    // If there are more users, the Greeter will handle that
                    if (LightDM.Users.count == 1) {
                        LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole));
                    }
                    greeter.forceActiveFocus();
                }
            }

            onUnlocked: hide()
            onSelected: {
                // Update launcher items for new user
                var user = LightDM.Users.data(uid, LightDM.UserRoles.NameRole);
                AccountsService.user = user;
                LauncherModel.setUser(user);
            }
            onTease: launcher.tease()
        }
    }

    InputFilterArea {
        anchors.fill: parent
        blockInput: true
    }

    Item {
        id: overlay

        anchors.fill: parent

        Panel {
            id: panel
            anchors.fill: parent //because this draws indicator menus
            indicatorsMenuWidth: parent.width > units.gu(60) ? units.gu(40) : parent.width
            indicators {
                hides: [launcher]
                available: !edgeDemo.active
            }
            fullscreenMode: false
            searchVisible: false
        }

        Launcher {
            id: launcher

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            dragAreaWidth: shell.edgeSize
            available: !edgeDemo.active
            onLauncherApplicationSelected: {
                shell.activateApplication("application:///" + appId + ".desktop")
            }
            onShownChanged: {
                if (shown) {
                    panel.indicators.hide()
                }
            }
            onDash: {
                greeter.hideRight()
                hide()
            }
            onShowDashHome: {
                SessionBroadcast.requestHomeShown(LightDM.Greeter.authenticationUser)
                greeter.hide()
            }
        }

        Notifications {
            id: notifications

            model: NotificationBackend.Model
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
                topMargin: panel.panelHeight + units.gu(1)
            }
            states: [
                State {
                    name: "narrow"
                    when: overlay.width <= units.gu(60)
                    AnchorChanges { target: notifications; anchors.left: parent.left }
                },
                State {
                    name: "wide"
                    when: overlay.width > units.gu(60)
                    AnchorChanges { target: notifications; anchors.left: undefined }
                    PropertyChanges { target: notifications; width: units.gu(38) }
                }
            ]

            InputFilterArea {
                anchors { left: parent.left; right: parent.right }
                height: parent.contentHeight
                blockInput: height > 0
            }
        }
    }

    OSKController {
        anchors.topMargin: panel.panelHeight
        anchors.fill: parent // as needs to know the geometry of the shell
    }

    Connections {
        id: powerConnection
        target: Powerd

        onDisplayPowerStateChange: {
            if (status == Powerd.Off) {
                greeter.show();
                edgeDemo.paused = true;
            } else if (status == Powerd.On) {
                edgeDemo.paused = false;
            }
        }
    }

    Connections {
        target: LightDM.URLDispatcher
        onDispatchURL: shell.activateApplication(url)
    }

    GreeterEdgeDemo {
        id: edgeDemo
        greeter: greeter
    }
}
