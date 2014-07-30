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
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Item {
    id: root

    function onPowerKeyPressed() {
        if (!powerKeyTimer.running) {
            powerKeyTimer.start();
        }
    }

    function onPowerKeyReleased() {
        powerKeyTimer.stop();
    }

    signal powerOffClicked();

    QtObject {
        id: d // private stuff

        property bool dialogShown: false

        function showPowerDialog() {
            if (!d.dialogShown) {
                d.dialogShown = true;
                PopupUtils.open(powerDialog, root, {"z": root.z});
            }
        }
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
        id: logoutDialog
        Dialog {
            id: dialogueLogout
            title: "Logout"
            text: "Are you sure that you want to logout?"
            Button {
                text: "Cancel"
                onClicked: {
                    PopupUtils.close(dialogueLogout);
                    d.dialogShown = false;
                }
            }
            Button {
                text: "Yes"
                onClicked: {
                    DBusUnitySessionService.Logout();
                    PopupUtils.close(dialogueLogout);
                    d.dialogShown = false;
                }
            }
        }
    }

    Component {
        id: shutdownDialog
        Dialog {
            id: dialogueShutdown
            title: "Shutdown"
            text: "Are you sure that you want to shutdown?"
            Button {
                text: "Cancel"
                onClicked: {
                    PopupUtils.close(dialogueShutdown);
                    d.dialogShown = false;
                }
            }
            Button {
                text: "Yes"
                onClicked: {
                    dBusUnitySessionServiceConnection.closeAllApps();
                    DBusUnitySessionService.Shutdown();
                    PopupUtils.close(dialogueShutdown);
                    d.dialogShown = false;
                }
            }
        }
    }

    Component {
        id: rebootDialog
        Dialog {
            id: dialogueReboot
            title: "Reboot"
            text: "Are you sure that you want to reboot?"
            Button {
                text: "Cancel"
                onClicked: {
                    PopupUtils.close(dialogueReboot)
                    d.dialogShown = false;
                }
            }
            Button {
                text: "Yes"
                onClicked: {
                    dBusUnitySessionServiceConnection.closeAllApps();
                    DBusUnitySessionService.Reboot();
                    PopupUtils.close(dialogueReboot);
                    d.dialogShown = false;
                }
            }
        }
    }

    Component {
        id: powerDialog
        Dialog {
            id: dialoguePower
            title: "Power"
            text: i18n.tr("Are you sure you would like to turn power off?")
            Button {
                text: i18n.tr("Power off")
                onClicked: {
                    dBusUnitySessionServiceConnection.closeAllApps();
                    PopupUtils.close(dialoguePower);
                    d.dialogShown = false;
                    root.powerOffClicked();
                }
            }
            Button {
                text: i18n.tr("Restart")
                onClicked: {
                    dBusUnitySessionServiceConnection.closeAllApps();
                    DBusUnitySessionService.Reboot();
                    PopupUtils.close(dialoguePower);
                    d.dialogShown = false;
                }
            }
            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    PopupUtils.close(dialoguePower);
                    d.dialogShown = false;
                }
            }
        }
    }


    Connections {
        id: dBusUnitySessionServiceConnection
        objectName: "dBusUnitySessionServiceConnection"
        target: DBusUnitySessionService

        function closeAllApps() {
            while (true) {
                var app = ApplicationManager.get(0);
                if (app === null) {
                    break;
                }
                ApplicationManager.stopApplication(app.appId);
            }
        }

        onLogoutRequested: {
            // Display a dialog to ask the user to confirm.
            if (!d.dialogShown) {
                d.dialogShown = true;
                PopupUtils.open(logoutDialog, root, {"z": root.z});
            }
        }

        onShutdownRequested: {
            // Display a dialog to ask the user to confirm.
            if (!d.dialogShown) {
                d.dialogShown = true;
                PopupUtils.open(shutdownDialog, root, {"z": root.z});
            }
        }

        onRebootRequested: {
            // Display a dialog to ask the user to confirm.
            if (!d.dialogShown) {
                d.dialogShown = true;
                PopupUtils.open(rebootDialog, root, {"z": root.z});
            }
        }

        onLogoutReady: {
            closeAllApps();
            Qt.quit();
        }
    }

}
