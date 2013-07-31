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

Item {
    id: applicationManager

    property var mainStageApplications: ApplicationManager.mainStageApplications
    property var sideStageApplications: ApplicationManager.sideStageApplications
    property var mainStageFocusedApplication: ApplicationManager.mainStageFocusedApplication
    property var sideStageFocusedApplication: ApplicationManager.sideStageFocusedApplication
    property bool sideStageEnabled: true
    signal focusRequested(string desktopFile)
    property bool keyboardVisible: ApplicationManager.keyboardVisible
    property int keyboardHeight: ApplicationManager.keyboardHeight

    Component.onCompleted: {
        // Start the watcher so that the ApplicationManager applications model can be populated.
        ApplicationManager.startWatcher();
    }

    function activateApplication(desktopFile, argument) {
        var application;
        application = getApplicationFromDesktopFile(desktopFile, ApplicationInfo.MainStage);
        if (application == null) {
            application = getApplicationFromDesktopFile(desktopFile, ApplicationInfo.SideStage);
        }
        if (application != null) {
            return application;
        }

        var execFlags = sideStageEnabled ? ApplicationManager.NoFlag : ApplicationManager.ForceMainStage;

        if (argument) {
            return ApplicationManager.startProcess(desktopFile, execFlags, [argument]);
        } else {
            return ApplicationManager.startProcess(desktopFile, execFlags);
        }
    }

    function stopProcess(application) {
        ApplicationManager.stopProcess(application)
    }

    function focusApplication(application) {
        if (application == null || application == undefined) {
            return;
        }

        ApplicationManager.focusApplication(application.handle);
    }

    function unfocusCurrentApplication() {
        ApplicationManager.unfocusCurrentApplication(ApplicationInfo.MainStage);
    }

    function moveRunningApplicationStackPosition(from, to, stage) {
        var applications;
        if (stage == ApplicationInfo.SideStage) {
            applications = ApplicationManager.sideStageApplications;
        } else {
            applications = ApplicationManager.mainStageApplications;
        }
        // FIXME: applications.move(0, 0) crashes
        if (from !== to && from >= 0 && to >= 0) applications.move(from, to);
    }

    function getApplicationFromDesktopFile(desktopFile, stage) {
        var foundSideStageApp, foundMainStageApp;

        foundMainStageApp = __find(desktopFile, ApplicationManager.mainStageApplications)
        if (stage == ApplicationInfo.MainStage) {
            return foundMainStageApp;
        }
        foundSideStageApp = __find(desktopFile, ApplicationManager.sideStageApplications)
        if (stage == ApplicationInfo.SideStage) {
            return foundSideStageApp;
        }

        // if stage not specified, return whichever app running on either stage
        return (foundMainStageApp) ? foundMainStageApp : foundSideStageApp;


        function __find(desktopFile, applications) {
            for (var i = 0; i < applications.count; i++ ) {
                var application = applications.get(i);
                if (application.desktopFile == desktopFile) {
                    return application;
                }
            }
            return null;
        }
    }

    Connections {
        target: ApplicationManager
        onFocusRequested: {
            // FIXME: hardcoded mapping from ApplicationManager.FavoriteApplications
            // enum to desktop files
            var desktopFile
            if (favoriteApplication == ApplicationManager.CameraApplication) {
                desktopFile = "/usr/share/applications/camera-app.desktop"
            } else if (favoriteApplication == ApplicationManager.GalleryApplication) {
                desktopFile = "/usr/share/applications/gallery-app.desktop"
            } else if (favoriteApplication == ApplicationManager.ShareApplication) {
                desktopFile = "/usr/share/applications/share-app.desktop"
            } else if (favoriteApplication == ApplicationManager.BrowserApplication) {
                desktopFile = "/usr/share/applications/webbrowser-app.desktop"
            } else if (favoriteApplication == ApplicationManager.PhoneApplication) {
                desktopFile = "/usr/share/applications/phone-app.desktop"
            } else if (favoriteApplication == ApplicationManager.DialerApplication) {
                desktopFile = "/usr/share/applications/dialer-app.desktop"
            } else if (favoriteApplication == ApplicationManager.MessagingApplication) {
                desktopFile = "/usr/share/applications/messaging-app.desktop"
            } else if (favoriteApplication == ApplicationManager.AddressbookApplication) {
                desktopFile = "/usr/share/applications/address-book-app.desktop"
            }

            applicationManager.focusRequested(desktopFile);
        }
    }
}
