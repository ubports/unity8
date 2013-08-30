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

import QtQuick 2.0
import Ubuntu.Application 0.1
import LightDM 0.1 as LightDM
import "Greeter"
import "Launcher"
import "Panel"
import "Components"
import "Components/Math.js" as MathLocal

BasicShell {
    id: shell

    function activateApplication(desktopFile, argument) {
        greeter.login()
        // TODO: support opening the app once inside user's session
    }

    Lockscreen {
        id: lockscreen
        hides: [launcher, panel.indicators]
        shown: false
        enabled: true
        showAnimation: StandardAnimation { property: "opacity"; to: 1 }
        hideAnimation: StandardAnimation { property: "opacity"; to: 0 }
        y: panel.panelHeight
        x: required ? 0 : - width
        width: parent.width
        height: parent.height - panel.panelHeight
        background: shell.background

        onUnlocked: lockscreen.hide()
        onCancel: greeter.show()

        Component.onCompleted: {
            if (LightDM.Users.count == 1) {
                LightDM.Greeter.authenticate(LightDM.Users.data(0, LightDM.UserRoles.NameRole))
                greeter.selected(0)
            }
        }
    }

    Connections {
        target: LightDM.Greeter

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
    }

    Greeter {
        id: greeter
        objectName: "greeter"

        available: true
        hides: [launcher, panel.indicators]
        shown: true

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
                    greeter.selected(0);
                }
                greeter.forceActiveFocus();
            }
            else if (LightDM.Greeter.promptless)
                login();
        }

        onUnlocked: login()
        onSelected: {
            // Update launcher items for new user
            var user = LightDM.Users.data(uid, LightDM.UserRoles.NameRole);
            AccountsService.setUser(user);
            LauncherModel.setUser(user);
        }

        onLeftTeaserPressedChanged: {
            if (leftTeaserPressed) {
                launcher.tease();
            }
        }
    }

    InputFilterArea {
        anchors.fill: parent
        blockInput: true
    }

    Revealer {
        id: greeterRevealer
        objectName: "greeterRevealer"

        property real animatedProgress: MathLocal.clamp(-dragPosition / closedValue, 0, 1)
        target: greeter
        width: greeter.width
        height: greeter.height
        handleSize: shell.edgeSize
        orientation: Qt.Horizontal
        enabled: !greeter.locked
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
            available: greeter.narrowMode && !edgeDemo.active
            onLauncherApplicationSelected: {
                shell.activateApplication(name)
            }
            onShownChanged: {
                if (shown) {
                    panel.indicators.hide()
                }
            }
        }
    }

    GreeterEdgeDemo {
        id: edgeDemo
        greeter: greeter
    }
}
