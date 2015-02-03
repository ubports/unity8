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

import QtQuick 2.0

import Unity.Application 0.1
import Unity.Session 0.1
import Ubuntu.Components 1.1
import LightDM 0.1 as LightDM

Item {
    id: root

    // to be set from outside, useful mostly for testing purposes
    property var unitySessionService: DBusUnitySessionService
    property var closeAllApps: function() {
        while (true) {
            var app = ApplicationManager.get(0);
            if (app === null) {
                break;
            }
            ApplicationManager.stopApplication(app.appId);
        }
    }

    function onPowerKeyPressed() {
        // FIXME: event.isAutoRepeat is always false on Nexus 4.
        // So we use powerKeyTimer.running to avoid the PowerOff key repeat
        // https://launchpad.net/bugs/1349416
        if (!powerKeyTimer.running) {
            powerKeyTimer.restart();
        }
    }

    function onPowerKeyReleased() {
        powerKeyTimer.stop();
    }

    signal powerOffClicked();

    QtObject {
        id: d // private stuff
        objectName: "dialogsPrivate"


        function showPowerDialog() {
            if (!dialogLoader.active) {
                dialogLoader.sourceComponent = powerDialogComponent;
                dialogLoader.active = true;
            }
        }
    }
    Loader {
        id: dialogLoader
        anchors.fill: parent
        active: false
    }

    Timer {
        id: powerKeyTimer
        interval: 2000
        repeat: false
        triggeredOnStart: false

        onTriggered: {
            d.showPowerDialog();
        }
    }

    Component {
        id: logoutDialogComponent
        ShellDialog {
            id: logoutDialog
            title: i18n.tr("Log out")
            text: i18n.tr("Are you sure you want to log out?")
            Button {
                text: i18n.tr("Lock")
                onClicked: {
                    LightDM.Greeter.showGreeter()
                    logoutDialog.hide();
                }
            }
            Button {
                text: i18n.tr("Log Out")
                onClicked: {
                    unitySessionService.logout();
                    logoutDialog.hide();
                }
            }
            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    logoutDialog.hide();
                }
            }
        }
    }

    Component {
        id: shutdownDialogComponent
        ShellDialog {
            id: shutdownDialog
            title: i18n.tr("Shut down")
            text: i18n.tr("Are you sure you want to shut down?")
            Button {
                text: i18n.tr("Reboot")
                onClicked: {
                    root.closeAllApps();
                    unitySessionService.reboot();
                    shutdownDialog.hide();
                }
            }
            Button {
                text: i18n.tr("Shutdown")
                onClicked: {
                    root.closeAllApps();
                    unitySessionService.shutdown();
                    shutdownDialog.hide();
                }
            }
            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    shutdownDialog.hide();
                }
            }
        }
    }

    Component {
        id: rebootDialogComponent
        ShellDialog {
            id: rebootDialog
            title: i18n.tr("Reboot")
            text: i18n.tr("Are you sure you want to reboot?")
            Button {
                text: i18n.tr("No")
                onClicked: {
                    rebootDialog.hide();
                }
            }
            Button {
                text: i18n.tr("Yes")
                onClicked: {
                    root.closeAllApps();
                    unitySessionService.reboot();
                    rebootDialog.hide();
                }
            }
        }
    }

    Component {
        id: powerDialogComponent
        ShellDialog {
            id: powerDialog
            title: i18n.tr("Power")
            text: i18n.tr("Are you sure you would like\nto power off?")
            Button {
                text: i18n.tr("Power off")
                onClicked: {
                    root.closeAllApps();
                    powerDialog.hide();
                    root.powerOffClicked();
                }
                color: UbuntuColors.red
            }
            Button {
                text: i18n.tr("Restart")
                onClicked: {
                    root.closeAllApps();
                    unitySessionService.reboot();
                    powerDialog.hide();
                }
                color: UbuntuColors.green
            }
            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    powerDialog.hide();
                }
                color: UbuntuColors.coolGrey
            }
        }
    }

    Connections {
        target: root.unitySessionService

        onLogoutRequested: {
            // Display a dialog to ask the user to confirm.
            if (!dialogLoader.active) {
                dialogLoader.sourceComponent = logoutDialogComponent;
                dialogLoader.active = true;
            }
        }

        onShutdownRequested: {
            // Display a dialog to ask the user to confirm.
            if (!dialogLoader.active) {
                dialogLoader.sourceComponent = shutdownDialogComponent;
                dialogLoader.active = true;
            }
        }

        onRebootRequested: {
            // Display a dialog to ask the user to confirm.
            if (!dialogLoader.active) {
                dialogLoader.sourceComponent = rebootDialogComponent;
                dialogLoader.active = true;
            }
        }

        onLogoutReady: {
            root.closeAllApps();
            Qt.quit();
        }
    }

}
