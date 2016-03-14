/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import QtTest 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Application 0.1
import Unity.Test 0.1

import ".."
import "../../../qml/Stages"
import "../../../qml/Components"

Rectangle {
    id: root
    color: "grey"
    width:  tabletStageLoader.width + controls.width
    height: tabletStageLoader.height

    property var greeter: { fullyShown: true }

    Loader {
        id: tabletStageLoader

        x: ((root.width - controls.width) - width) / 2
        y: (root.height - height) / 2
        width: units.gu(160*0.7)
        height: units.gu(100*0.7)

        focus: true

        property bool itemDestroyed: false
        sourceComponent: Component {
            TabletStage {
                anchors.fill: parent
                Component.onDestruction: {
                    tabletStageLoader.itemDestroyed = true;
                }
                dragAreaWidth: units.gu(2)
                maximizedAppTopMargin: units.gu(3)
                interactive: true
                shellOrientation: Qt.LandscapeOrientation
                nativeWidth: width
                nativeHeight: height
                orientations: Orientations {
                    native_: Qt.LandscapeOrientation
                    primary: Qt.LandscapeOrientation
                }
                focus: true
            }
        }
    }

    Rectangle {
        id: controls
        color: "darkgrey"
        width: units.gu(30)
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            EdgeBarrierControls {
                id: edgeBarrierControls
                text: "Drag here to pull out spread"
                backgroundColor: "blue"
                onDragged: { tabletStageLoader.item.pushRightEdge(amount); }
                Component.onCompleted: {
                    edgeBarrierControls.target = testCase.findChild(tabletStageLoader, "edgeBarrierController");
                }
            }
            ApplicationCheckBox {
                id: webbrowserCheckBox
                appId: "webbrowser-app"
            }
            ApplicationCheckBox {
                id: galleryCheckBox
                appId: "gallery-app"
            }
            ApplicationCheckBox {
                id: dialerCheckBox
                appId: "dialer-app"
            }
            ApplicationCheckBox {
                id: facebookCheckBox
                appId: "facebook-webapp"
            }
        }
    }

    UnityTestCase {
        id: testCase
        name: "TabletStage"
        when: windowShown

        property Item tabletStage: tabletStageLoader.status === Loader.Ready ? tabletStageLoader.item : null

        function init() {
            tabletStageLoader.active = true;
            tryCompare(tabletStageLoader, "status", Loader.Ready);

            // this is very strange, but sometimes the test starts without
            // TabletStage components having finished loading themselves
            var appWindow = null;
            while (!appWindow) {
                appWindow = findChild(tabletStage, "appWindow_unity8-dash");
                if (!appWindow) {
                    console.log("didn't find appWindow_unity8-dash in " + tabletStage + ". Trying again...");
                    wait(50);
                }
            }

            waitUntilAppSurfaceShowsUp("unity8-dash");
        }

        function cleanup() {
            tabletStageLoader.itemDestroyed = false;
            tabletStageLoader.active = false;

            tryCompare(tabletStageLoader, "status", Loader.Null);
            tryCompare(tabletStageLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(tabletStageLoader, "itemDestroyed", true);

            // kill all (fake) running apps
            webbrowserCheckBox.checked = false;
            galleryCheckBox.checked = false;
            dialerCheckBox.checked = false;
            facebookCheckBox.checked = false;
        }

        function waitUntilAppSurfaceShowsUp(appId) {
            var appWindow = findChild(tabletStage, "appWindow_" + appId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function switchToApp(targetAppId) {
            touchFlick(tabletStage,
                tabletStage.width - (tabletStage.dragAreaWidth / 2), tabletStage.height / 2,
                tabletStage.x + 1, tabletStage.height / 2);

            var spreadView = findChild(tabletStage, "spreadView");
            verify(spreadView);
            tryCompare(spreadView, "phase", 2);
            tryCompare(spreadView, "flicking", false);
            tryCompare(spreadView, "moving", false);

            waitUntilAppDelegateStopsMoving(targetAppId);

            var targetAppWindow = findChild(tabletStage, "appWindow_" + targetAppId);
            tap(targetAppWindow, 10, 10);
        }

        function waitUntilAppDelegateStopsMoving(targetAppId)
        {
            var targetAppDelegate = findChild(tabletStage, "tabletSpreadDelegate_" + targetAppId);
            verify(targetAppDelegate);
            var lastValue = undefined;
            do {
                lastValue = targetAppDelegate.animatedProgress;
                wait(300);
            } while (lastValue != targetAppDelegate.animatedProgress);
        }

        function test_tappingSwitchesFocusBetweenStages() {
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserCheckBox.appId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            compare(webbrowserApp.stage, ApplicationInfoInterface.MainStage);
            tryCompare(webbrowserApp.session.lastSurface, "activeFocus", true);

            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerCheckBox.appId);
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            compare(dialerApp.stage, ApplicationInfoInterface.SideStage);
            tryCompare(dialerApp.session.lastSurface, "activeFocus", true);
            tryCompare(webbrowserApp.session.lastSurface, "activeFocus", false);

            // Tap on the main stage application and check if the focus
            // has been passed to it.

            var webbrowserWindow = findChild(tabletStage, "appWindow_" + webbrowserApp.appId);
            verify(webbrowserWindow);
            tap(webbrowserWindow);

            tryCompare(dialerApp.session.lastSurface, "activeFocus", false);
            tryCompare(webbrowserApp.session.lastSurface, "activeFocus", true);

            // Now tap on the side stage application and check if the focus
            // has been passed back to it.

            var dialerWindow = findChild(tabletStage, "appWindow_" + dialerApp.appId);
            verify(dialerWindow);
            tap(dialerWindow);

            tryCompare(dialerApp.session.lastSurface, "activeFocus", true);
            tryCompare(webbrowserApp.session.lastSurface, "activeFocus", false);
        }

        function test_closeAppInSideStage() {
            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerCheckBox.appId);

            performEdgeSwipeToShowAppSpread();

            var appDelegate = findChild(tabletStage, "tabletSpreadDelegate_" + dialerCheckBox.appId);
            verify(appDelegate);
            tryCompare(appDelegate, "swipeToCloseEnabled", true);

            swipeAppUpwards(dialerCheckBox.appId);

            // Check that dialer-app has been closed

            tryCompareFunction(function() {
                return findChild(tabletStage, "appWindow_" + dialerCheckBox.appId);
            }, null);

            tryCompareFunction(function() {
                return ApplicationManager.findApplication(dialerCheckBox.appId);
            }, null);
        }

        function performEdgeSwipeToShowAppSpread() {
            var touchStartY = tabletStage.height / 2;
            touchFlick(tabletStage,
                       tabletStage.width - 1, touchStartY,
                       0, touchStartY);

            var spreadView = findChild(tabletStage, "spreadView");
            verify(spreadView);
            tryCompare(spreadView, "phase", 2);
            tryCompare(spreadView, "flicking", false);
            tryCompare(spreadView, "moving", false);
        }

        function swipeAppUpwards(appId) {
            var appWindow = findChild(tabletStage, "appWindow_" + appId);
            verify(appWindow);

            touchFlick(appWindow,
                    appWindow.width / 2, appWindow.height / 2,
                    appWindow.width / 2, -appWindow.height / 2);
        }

        function test_suspendsAndResumesAppsInMainStage() {
            webbrowserCheckBox.checked = true;
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            compare(webbrowserApp.stage, ApplicationInfoInterface.MainStage);

            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);

            galleryCheckBox.checked = true;
            var galleryApp = ApplicationManager.findApplication(galleryCheckBox.appId);
            compare(galleryApp.stage, ApplicationInfoInterface.MainStage);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);

            switchToApp(webbrowserApp.appId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);

            switchToApp(galleryApp.appId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);
        }


        function test_foregroundMainAndSideStageAppsAreKeptRunning() {

            var stagesPriv = findInvisibleChild(tabletStage, "stagesPriv");
            verify(stagesPriv);

            // launch two main stage apps
            // gallery will be on foreground and webbrowser on background

            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserCheckBox.appId)
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            compare(webbrowserApp.stage, ApplicationInfoInterface.MainStage);

            galleryCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(galleryCheckBox.appId)
            var galleryApp = ApplicationManager.findApplication(galleryCheckBox.appId);
            compare(galleryApp.stage, ApplicationInfoInterface.MainStage);

            compare(stagesPriv.mainStageAppId, galleryCheckBox.appId);

            // then launch two side stage apps
            // facebook will be on foreground and dialer on background

            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerCheckBox.appId)
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            compare(dialerApp.stage, ApplicationInfoInterface.SideStage);

            facebookCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(facebookCheckBox.appId)
            var facebookApp = ApplicationManager.findApplication(facebookCheckBox.appId);
            compare(facebookApp.stage, ApplicationInfoInterface.SideStage);

            compare(stagesPriv.sideStageAppId, facebookCheckBox.appId);

            // Now check that the foreground apps are running and that the background ones
            // are suspended

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(facebookApp, "state", ApplicationInfoInterface.Running);
            tryCompare(dialerApp, "state", ApplicationInfoInterface.Suspended);

            switchToApp(dialerCheckBox.appId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Running);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(facebookApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(dialerApp, "state", ApplicationInfoInterface.Running);

            switchToApp(webbrowserCheckBox.appId);

            tryCompare(galleryApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(webbrowserApp, "state", ApplicationInfoInterface.Running);
            tryCompare(facebookApp, "state", ApplicationInfoInterface.Suspended);
            tryCompare(dialerApp, "state", ApplicationInfoInterface.Running);
        }

        function test_foregroundAppsAreSuspendedWhenStageIsSuspended() {
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserCheckBox.appId)
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            compare(webbrowserApp.stage, ApplicationInfoInterface.MainStage);

            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerCheckBox.appId)
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            compare(dialerApp.stage, ApplicationInfoInterface.SideStage);


            compare(webbrowserApp.requestedState, ApplicationInfoInterface.RequestedRunning);
            compare(dialerApp.requestedState, ApplicationInfoInterface.RequestedRunning);

            tabletStage.suspended = true;

            tryCompare(webbrowserApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);
            tryCompare(dialerApp, "requestedState", ApplicationInfoInterface.RequestedSuspended);

            tabletStage.suspended = false;

            tryCompare(webbrowserApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
            tryCompare(dialerApp, "requestedState", ApplicationInfoInterface.RequestedRunning);
        }

        function test_mouseEdgePush() {
            var spreadView = findChild(tabletStageLoader, "spreadView")
            mouseMove(tabletStageLoader, tabletStageLoader.width -  1, units.gu(10));
            for (var i = 0; i < units.gu(10); i++) {
                tabletStageLoader.item.pushRightEdge(1);
            }
            tryCompare(spreadView, "phase", 2);
        }
    }
}
