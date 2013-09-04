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
import Unity.Application 0.1
import Utils 0.1

Item {
    id: applicationManager

    property var mainStageApplications: mainStageModel
    property var sideStageApplications: sideStageModel
    property var mainStageFocusedApplication: null
    property var sideStageFocusedApplication: null
    property bool sideStageEnabled: true
    signal focusRequested(string desktopFile)
    property bool keyboardVisible: ApplicationManager.keyboardVisible
    property int keyboardHeight: ApplicationManager.keyboardHeight

    property bool fake: ApplicationManager.fake ? ApplicationManager.fake : false

    SortFilterProxyModel {
        id: mainStageModel
        model: ApplicationManager
        dynamicSortFilter: true
        filterRole: ApplicationManager.RoleStage
        filterRegExp: RegExp(ApplicationInfo.MainStage)

        onCountChanged: { print("MODEL Main:", count, ApplicationManager.RoleStage, ApplicationManager.RoleFocused)
            mainStageFocusedApplication = ApplicationManager.get(mainStageModel.findFirst(ApplicationManager.RoleFocused, true));
            print("MS", mainStageFocusedApplication)
        }
        onLayoutChanged: print("LAYOUT")
        onDataChanged: print("DATA")
    }

    SortFilterProxyModel {
        id: sideStageModel
        model: ApplicationManager
        dynamicSortFilter: true
        filterRole: ApplicationManager.RoleStage
        filterRegExp: RegExp(ApplicationInfo.SideStage)

        onDataChanged: { print("MODEL Side", count)
            sideStageFocusedApplication = ApplicationManager.get(sideStageModel.findFirst(ApplicationManager.RoleFocused, true));
            print("SS", sideStageFocusedApplication)
        }
    }

    function activateApplication(desktopFile, argument) {
        var appId;

        // HACK: might be called with appId, but mostly with desktopFile
        if (desktopFile.indexOf(".desktop") = -1) {
            appId = desktopFileToAppId(desktopFile);
        } else {
            appId = desktopFile;
        }

        var application = ApplicationManager.findApplication(appId);
        if (application !== null) {
            return application;
        }

        var execFlags = sideStageEnabled ? ApplicationManager.NoFlag : ApplicationManager.ForceMainStage;

        if (argument) {
            return ApplicationManager.startApplication(appId, execFlags, [argument]);
        } else {
            return ApplicationManager.startApplication(appId, execFlags);
        }
    }

    function stopProcess(application) {
        var appId;

        // HACK: might be called with appId, or else with Application object
        if (typeof application == "string") {
            appId = desktopFileToAppId(application.desktopFile);
        } else {
            appId = application;
        }

        ApplicationManager.stopProcess(appId);
    }

    function focusApplication(application) {
        if (application == null || application == undefined) {
            return;
        }

        ApplicationManager.focusApplication(application.appId);
    }

    function unfocusCurrentApplication() {
        ApplicationManager.unfocusCurrentApplication();
    }

    function moveRunningApplicationStackPosition(from, to, stage) { //FIXME: stage unused!
        if (from !== to && from >= 0 && to >= 0) ApplicationManager.move(from, to);
    }

    function getApplicationFromDesktopFile(desktopFile, stage) {
        var foundSideStageApp, foundMainStageApp;
        var appId = desktopFileToAppId(desktopFile);

        for (var i = 0, len = ApplicationManager.count; i < len; i++ ) {
            var app = ApplicationManager.get(i);

            // if stage not specified, return whichever app running on either stage
            if (app.appId == appId && (stage == undefined || app.stage == stage)) {
                return app;
            }
        }
    }

    function desktopFileToAppId(desktopFile) {
        var right = desktopFile.lastIndexOf(".desktop");
        var left = desktopFile.lastIndexOf("/");
        if (left == -1 || right == -1 || left == right) {
            console.log("ApplicationManagerWrapper: unable to extract appId from '" + desktopFile + "'");
            return "";
        }
        return desktopFile.substring(left+1, right);
    }

    function appIdToDesktopFile(desktopFile) {
        return "/usr/share/applications/" + desktopFile + ".desktop"
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
