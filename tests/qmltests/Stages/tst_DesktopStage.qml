/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import Ubuntu.Components.ListItems 1.3
import Unity.Application 0.1
import Unity.Test 0.1
import WindowManager 0.1
import Utils 0.1

import ".." // For EdgeBarrierControls
import "../../../qml/Stages"
import "../../../qml/Components"
import "../../../qml/Components/PanelState"

Item {
    id: root
    width:  desktopStageLoader.width + controls.width
    height: desktopStageLoader.height

    property var greeter: { fullyShown: true }

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    Component.onCompleted: {
        theme.name = "Ubuntu.Components.Themes.SuruDark";
        resetGeometry();
    }

    function resetGeometry() {
        // ensures apps which are tested decorations are in view.
        WindowStateStorage.clear();
        WindowStateStorage.geometry = {
            'unity8-dash': Qt.rect(0, units.gu(3), units.gu(50), units.gu(40)),
            'dialer-app': Qt.rect(units.gu(51), units.gu(3), units.gu(50), units.gu(40)),
            'gmail-webapp': Qt.rect(0, units.gu(44), units.gu(50), units.gu(40)),
            'twitter-webapp': Qt.rect(units.gu(51), units.gu(44), units.gu(50), units.gu(40))
        }
    }

    TopLevelSurfaceList {
        id: topSurfaceList
        applicationsModel: ApplicationManager
    }

    Loader {
        id: desktopStageLoader
        x: ((root.width - controls.width) - width) / 2
        y: (root.height - height) / 2
        width: units.gu(160*0.9)
        height: units.gu(100*0.9)

        focus: true

        property bool itemDestroyed: false
        sourceComponent: Component {
            DesktopStage {
                anchors.fill: parent
                background: "../../../qml/graphics/tablet_background.jpg"
                focus: true

                Component.onCompleted: {
                    edgeBarrierControls.target = testCase.findChild(this, "edgeBarrierController");
                }
                Component.onDestruction: {
                    desktopStageLoader.itemDestroyed = true;
                }
                orientations: Orientations {}
                applicationManager: ApplicationManager
                topLevelSurfaceList: topSurfaceList
            }
        }
    }

    Rectangle {
        id: controls
        width: units.gu(30)
        color: theme.palette.normal.background
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        Flickable {
            anchors.fill: parent
            contentHeight: controlsColumn.height
            Column {
                id: controlsColumn
                spacing: units.gu(1)

                Button {
                    text: "Make surface slow to resize"
                    activeFocusOnPress: false
                    onClicked: {
                        if (ApplicationManager.focusedApplicationId) {
                            var surface = ApplicationManager.findApplication(ApplicationManager.focusedApplicationId).surfaceList.get(0);
                            surface.slowToResize = true;
                        }
                    }
                }

                EdgeBarrierControls {
                    id: edgeBarrierControls
                    text: "Drag here to pull out spread"
                    backgroundColor: "blue"
                    onDragged: { desktopStageLoader.item.pushRightEdge(amount); }
                }

                Divider {}

                Repeater {
                    model: ApplicationManager.availableApplications
                    ApplicationCheckBox {
                        appId: modelData
                    }
                }

                SurfaceManagerControls { }
            }
        }
    }

    UnityTestCase {
        id: testCase
        name: "DesktopStage"
        when: windowShown

        property Item desktopStage: desktopStageLoader.status === Loader.Ready ? desktopStageLoader.item : null

        function init() {
            // wait until unity8-dash is up and running.
            // it's started automatically by ApplicationManager mock implementation
            tryCompare(ApplicationManager, "count", 1);
            var dashApp = ApplicationManager.findApplication("unity8-dash");
            verify(dashApp);
            tryCompare(dashApp, "state", ApplicationInfoInterface.Running);

            tryCompare(topSurfaceList, "count", 1);
            tryCompareFunction(function(){return topSurfaceList.surfaceAt(0) != null;}, true);
            compare(MirFocusController.focusedSurface, topSurfaceList.surfaceAt(0));
        }

        function cleanup() {
            desktopStageLoader.itemDestroyed = false;
            desktopStageLoader.active = false;

            tryCompare(desktopStageLoader, "status", Loader.Null);
            tryCompare(desktopStageLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(desktopStageLoader, "itemDestroyed", true);

            killApps();

            root.resetGeometry();

            desktopStageLoader.active = true;
            tryCompare(desktopStageLoader, "status", Loader.Ready);

        }

        function waitUntilAppSurfaceShowsUp(surfaceId) {
            var appDelegate = findChild(desktopStage, "appDelegate_" + surfaceId);
            verify(appDelegate);
            var appWindow = findChild(appDelegate, "appWindow");
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        /*
            Returns the appDelegate of the first surface created by the app with the specified appId
         */
        function startApplication(appId) {
            try {
                var app = ApplicationManager.findApplication(appId);
                if (app) {
                    for (var i = 0; i < topSurfaceList.count; i++) {
                        if (topSurfaceList.applicationAt(i).appId === appId) {
                            var appRepeater = findChild(desktopStage, "appRepeater");
                            verify(appRepeater);
                            return appRepeater.itemAt(i);
                        }
                    }
                }

                var surfaceId = topSurfaceList.nextId;
                app = ApplicationManager.startApplication(appId);
                verify(app);
                waitUntilAppSurfaceShowsUp(surfaceId);
                compare(app.surfaceList.count, 1);

                return findChild(desktopStage, "appDelegate_" + surfaceId);
            } catch(err) {
                throw new Error("startApplication("+appId+") called from line " +  util.callerLine(1) + " failed!");
            }
        }

        function maximizeAppDelegate(appDelegate) {
            var maximizeButton = findChild(appDelegate, "maximizeWindowButton");
            if (!maximizeButton) {
                fail("Could not find maximizeWindowButton of appDelegate=" + appDelegate);
            }
            mouseClick(maximizeButton);

            try {
                tryCompare(appDelegate, "visuallyMaximized", true);
            } catch(err) {
                fail("appDelegate.visuallyMaximized !== true");
            }
        }

        function test_appFocusSwitch_data() {
            return [
                {tag: "dash to dialer", apps: [ "unity8-dash", "dialer-app", "gmail-webapp" ], focusfrom: 0, focusTo: 1 },
                {tag: "dialer to dash", apps: [ "unity8-dash", "dialer-app", "gmail-webapp" ], focusfrom: 1, focusTo: 0 },
            ]
        }

        function test_appFocusSwitch(data) {
            data.apps.forEach(startApplication);

            ApplicationManager.requestFocusApplication(data.apps[data.focusfrom]);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusfrom]).surfaceList.get(0), "activeFocus", true);

            ApplicationManager.requestFocusApplication(data.apps[data.focusTo]);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusTo]).surfaceList.get(0), "activeFocus", true);
        }

        function test_tappingOnWindowChangesFocusedApp_data() {
            return [
                {tag: "dash to dialer", apps: [ "unity8-dash", "dialer-app", "gmail-webapp"], focusfrom: 0, focusTo: 1 },
                {tag: "dialer to dash", apps: [ "unity8-dash", "dialer-app", "gmail-webapp"], focusfrom: 1, focusTo: 0 }
            ]
        }

        function test_tappingOnWindowChangesFocusedApp(data) {
            var appDelegates = [];
            for (var i = 0; i < data.apps.length; i++) {
                appDelegates[i] = startApplication(data.apps[i]);
            }
            var fromDelegate = appDelegates[data.focusfrom];
            var toDelegate = appDelegates[data.focusTo];

            var fromAppWindow = findChild(fromDelegate, "appWindow");
            verify(fromAppWindow);
            tap(fromAppWindow);
            compare(fromDelegate.surface.activeFocus, true);
            compare(MirFocusController.focusedSurface, fromDelegate.surface);

            var toAppWindow = findChild(toDelegate, "appWindow");
            verify(toAppWindow);
            tap(toAppWindow);
            compare(toDelegate.surface.activeFocus, true);
            compare(MirFocusController.focusedSurface, toDelegate.surface);
        }

        function test_clickingOnWindowChangesFocusedApp_data() {
            return test_tappingOnWindowChangesFocusedApp_data(); // reuse test data
        }

        function test_clickingOnWindowChangesFocusedApp(data) {
            var appDelegates = [];
            for (var i = 0; i < data.apps.length; i++) {
                appDelegates[i] = startApplication(data.apps[i]);
            }
            var fromDelegate = appDelegates[data.focusfrom];
            var toDelegate = appDelegates[data.focusTo];

            var fromAppWindow = findChild(fromDelegate, "appWindow");
            verify(fromAppWindow);
            mouseClick(fromAppWindow);
            compare(fromDelegate.surface.activeFocus, true);
            compare(MirFocusController.focusedSurface, fromDelegate.surface);

            var toAppWindow = findChild(toDelegate, "appWindow");
            verify(toAppWindow);
            mouseClick(toAppWindow);
            compare(toDelegate.surface.activeFocus, true);
            compare(MirFocusController.focusedSurface, toDelegate.surface);
        }

        function test_tappingOnDecorationFocusesApplication_data() {
            return [
                {tag: "dash to dialer", apps: [ "unity8-dash", "dialer-app", "gmail-webapp"], focusfrom: 0, focusTo: 1 },
                {tag: "dialer to dash", apps: [ "unity8-dash", "dialer-app", "gmail-webapp"], focusfrom: 1, focusTo: 0 }
            ]
        }

        function findDecoratedWindow(surfaceId) {
            var appDelegate = findChild(desktopStage, "appDelegate_" + surfaceId);
            if (!appDelegate) {
                console.warn("Could not find appDelegate for surfaceId="+surfaceId);
                return null;
            }
            return findChild(appDelegate, "decoratedWindow");
        }

        function findWindowDecoration(surfaceId) {
            var appDelegate = findChild(desktopStage, "appDelegate_" + surfaceId);
            if (!appDelegate) {
                console.warn("Could not find appDelegate for surfaceId="+surfaceId);
                return null;
            }
            return findChild(appDelegate, "appWindowDecoration");
        }

        function test_tappingOnDecorationFocusesApplication(data) {
            var appDelegates = [];
            for (var i = 0; i < data.apps.length; i++) {
                appDelegates[i] = startApplication(data.apps[i]);
            }

            var fromDelegate = appDelegates[data.focusfrom];
            var toDelegate = appDelegates[data.focusTo];

            var fromAppDecoration = findChild(fromDelegate, "appWindowDecoration");
            verify(fromAppDecoration);
            tap(fromAppDecoration);

            tryCompare(fromDelegate.surface, "activeFocus", true);

            var toAppDecoration = findChild(toDelegate, "appWindowDecoration");
            verify(toAppDecoration);

            // FIXME: Wait a bit before the second tap or the window decoration will say it got double clicked.
            // No idea why.
            wait(700);

            tap(toAppDecoration);

            tryCompare(toDelegate.surface, "activeFocus", true);
        }

        function test_clickingOnDecorationFocusesApplication_data() {
            return test_tappingOnDecorationFocusesApplication_data(); // reuse test data
        }

        function test_clickingOnDecorationFocusesApplication(data) {
            var appDelegates = [];
            for (var i = 0; i < data.apps.length; i++) {
                appDelegates[i] = startApplication(data.apps[i]);
            }
            var fromDelegate = appDelegates[data.focusfrom];
            var toDelegate = appDelegates[data.focusTo];

            var fromAppDecoration = findChild(fromDelegate, "appWindowDecoration");
            verify(fromAppDecoration);
            mouseClick(fromAppDecoration);
            tryCompare(fromDelegate.surface, "activeFocus", true);

            var toAppDecoration = findChild(toDelegate, "appWindowDecoration");
            verify(toAppDecoration);
            mouseClick(toAppDecoration);
            tryCompare(toDelegate.surface, "activeFocus", true);
        }

        function test_windowMaximize() {
            var dialerDelegate = startApplication("dialer-app");
            startApplication("camera-app");

            tryCompareFunction(function(){ return dialerDelegate.surface !== null; }, true);
            dialerDelegate.surface.requestFocus();
            tryCompare(dialerDelegate, "focus", true);

            keyClick(Qt.Key_Up, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+Up shortcut to maximize
            tryCompare(dialerDelegate, "maximized", true);
            tryCompare(dialerDelegate, "minimized", false);
        }

        function test_windowMaximizeLeft() {
            var dialerDelegate = startApplication("dialer-app");
            startApplication("camera-app");

            tryCompareFunction(function(){ return dialerDelegate.surface !== null; }, true);
            dialerDelegate.surface.requestFocus();
            tryCompare(dialerDelegate, "focus", true);

            keyClick(Qt.Key_Left, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+Left shortcut to maximizeLeft
            tryCompare(dialerDelegate, "maximized", false);
            tryCompare(dialerDelegate, "minimized", false);
            tryCompare(dialerDelegate, "maximizedLeft", true);
            tryCompare(dialerDelegate, "maximizedRight", false);
        }

        function test_windowMaximizeRight() {
            var dialerDelegate = startApplication("dialer-app");
            startApplication("camera-app");

            tryCompareFunction(function(){ return dialerDelegate.surface !== null; }, true);
            dialerDelegate.surface.requestFocus();
            tryCompare(dialerDelegate, "focus", true);

            keyClick(Qt.Key_Right, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+Right shortcut to maximizeRight
            tryCompare(dialerDelegate, "maximized", false);
            tryCompare(dialerDelegate, "minimized", false);
            tryCompare(dialerDelegate, "maximizedLeft", false);
            tryCompare(dialerDelegate, "maximizedRight", true);
        }

        function test_windowMinimize() {
            var dialerDelegate = startApplication("dialer-app");
            startApplication("camera-app");

            tryCompareFunction(function(){ return dialerDelegate.surface !== null; }, true);
            dialerDelegate.surface.requestFocus();
            tryCompare(dialerDelegate, "focus", true);

            keyClick(Qt.Key_Down, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+Down shortcut to minimize
            tryCompare(dialerDelegate, "maximized", false);
            tryCompare(dialerDelegate, "minimized", true);
            verify(ApplicationManager.focusedApplicationId != ""); // verify we don't lose focus when minimizing an app
        }

        function test_windowMinimizeAll() {
            var apps = ["unity8-dash", "dialer-app", "camera-app"];
            apps.forEach(startApplication);
            verify(topSurfaceList.count == 3);
            keyClick(Qt.Key_D, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+D shortcut to minimize all
            tryCompare(ApplicationManager, "focusedApplicationId", ""); // verify no app is focused
        }

        function test_windowClose() {
            var dialerSurfaceId = topSurfaceList.nextId;
            var dialerDelegate = startApplication("dialer-app");
            verify(topSurfaceList.indexForId(dialerSurfaceId) !== -1);
            startApplication("gmail-webapp");
            verify(topSurfaceList.count == 3);

            mouseClick(dialerDelegate);

            var desktopStagePriv = findInvisibleChild(desktopStage, "DesktopStagePrivate");
            tryCompare(desktopStagePriv, "focusedAppDelegate", dialerDelegate);

            keyClick(Qt.Key_F4, Qt.AltModifier); // Alt+F4 shortcut to close

            // verify the surface is gone
            tryCompare(topSurfaceList, "count", 2);
            verify(topSurfaceList.indexForId(dialerSurfaceId) === -1);
        }

        function test_windowMaximizeHorizontally() {
            var dialerDelegate = startApplication("dialer-app");

            var dialerMaximizeButton = findChild(dialerDelegate, "maximizeWindowButton");
            verify(dialerMaximizeButton);

            // RMB to maximize horizontally
            mouseClick(dialerMaximizeButton, dialerMaximizeButton.width/2, dialerMaximizeButton.height/2, Qt.RightButton);
            tryCompare(dialerDelegate, "windowState", WindowStateStorage.WindowStateMaximizedHorizontally);

            // click again to restore
            mouseClick(dialerMaximizeButton);
            tryCompare(dialerDelegate, "windowState", WindowStateStorage.WindowStateNormal);
        }

        function test_windowMaximizeVertically() {
            var dialerDelegate = startApplication("dialer-app");

            var dialerMaximizeButton = findChild(dialerDelegate, "maximizeWindowButton");
            verify(dialerMaximizeButton);

            // MMB to maximize vertically
            mouseClick(dialerMaximizeButton, dialerMaximizeButton.width/2, dialerMaximizeButton.height/2, Qt.MiddleButton);
            tryCompare(dialerDelegate, "windowState", WindowStateStorage.WindowStateMaximizedVertically);

            // click again to restore
            mouseClick(dialerMaximizeButton);
            tryCompare(dialerDelegate, "windowState", WindowStateStorage.WindowStateNormal);
        }

        function test_smashCursorKeys() {
            var apps = ["dialer-app", "gmail-webapp"];
            apps.forEach(startApplication);
            verify(topSurfaceList.count == 3);
            keyClick(Qt.Key_D, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+D shortcut to minimize all
            tryCompare(MirFocusController, "focusedSurface", null); // verify no surface is focused

            // now try pressing all 4 arrow keys + ctrl + meta
            keyClick(Qt.Key_Up | Qt.Key_Down | Qt.Key_Left | Qt.Key_Right, Qt.MetaModifier|Qt.ControlModifier); // smash it!!!
            tryCompare(MirFocusController, "focusedSurface", null); // verify still no surface is focused
        }

        function test_minimizeApplicationHidesSurface() {
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurface = topSurfaceList.surfaceAt(0);
            var dashSurfaceId = topSurfaceList.idAt(0);

            var decoratedWindow = findDecoratedWindow(dashSurfaceId);
            verify(decoratedWindow);

            tryCompare(dashSurface, "visible", true);
            decoratedWindow.minimizeClicked();
            tryCompare(dashSurface, "visible", false);
        }

        function test_maximizeApplicationHidesSurfacesBehindIt() {
            var dashDelegate = startApplication("unity8-dash");
            var dialerDelegate = startApplication("dialer-app");
            var gmailDelegate = startApplication("gmail-webapp");

            // maximize without raising
            dialerDelegate.maximize();
            tryCompare(dialerDelegate, "visuallyMaximized", true);

            tryCompare(dashDelegate.surface, "visible", false);
            compare(gmailDelegate.surface.visible, true);

            // restore without raising
            dialerDelegate.restoreFromMaximized();
            compare(dashDelegate.surface.visible, true);
            compare(gmailDelegate.surface.visible, true);
        }

        function test_applicationsBecomeVisibleWhenOccludingAppRemoved() {
            var dashApp = topSurfaceList.applicationAt(0);

            var dialerSurfaceId = topSurfaceList.nextId;
            var dialerDelegate = startApplication("dialer-app");
            verify(dialerDelegate);
            var dialerApp = dialerDelegate.application;

            var dialerMaximizeButton = findChild(dialerDelegate, "maximizeWindowButton");
            verify(dialerMaximizeButton);
            mouseClick(dialerMaximizeButton);

            var mapSurfaceId = topSurfaceList.nextId;
            var mapDelegate = startApplication("map");
            verify(mapDelegate);
            var mapApp = mapDelegate.application;

            var gmailSurfaceId = topSurfaceList.nextId;
            var gmailDelegate = startApplication("gmail-webapp");
            verify(gmailDelegate);

            var gmailMaximizeButton = findChild(gmailDelegate, "maximizeWindowButton");
            verify(gmailMaximizeButton);
            mouseClick(gmailMaximizeButton);

            tryCompare(dialerDelegate, "visuallyMaximized", true);
            tryCompare(gmailDelegate, "visuallyMaximized", true);

            tryCompare(dashApp.surfaceList.get(0), "visible", false);
            tryCompare(dialerApp.surfaceList.get(0), "visible", false);
            tryCompare(mapApp.surfaceList.get(0), "visible", false);

            ApplicationManager.stopApplication("gmail-webapp");

            tryCompare(mapApp.surfaceList.get(0), "visible", true);
            tryCompare(dialerApp.surfaceList.get(0), "visible", true);
            tryCompare(dashApp.surfaceList.get(0), "visible", false); // still occluded by maximised dialer
        }

        function test_maximisedAppStaysVisibleWhenAppStarts() {
            var dashDelegate = startApplication("unity8-dash");

            // maximize
            var dashMaximizeButton = findChild(dashDelegate, "maximizeWindowButton");
            verify(dashMaximizeButton);
            mouseClick(dashMaximizeButton);
            tryCompare(dashDelegate, "visuallyMaximized", true);

            var dialerDelegate = startApplication("dialer-app");
            verify(dialerDelegate);

            compare(dialerDelegate.visible, true, "Dialer should be visible");
            compare(dashDelegate.visible, true, "Dash should still be visible");
        }

        function test_occlusionWithMultipleMaximized() {
            var dashAppDelegate = startApplication("unity8-dash");

            var dialerAppDelegate = startApplication("dialer-app");

            var facebookAppDelegate = startApplication("facebook-webapp");

            // all of them are in restored state now. all should be visible
            tryCompare(dashAppDelegate, "visible", true);
            tryCompare(dialerAppDelegate, "visible", true);
            tryCompare(facebookAppDelegate, "visible", true);

            // Maximize the topmost and make sure the other two are hidden
            facebookAppDelegate.maximize();
            tryCompare(dashAppDelegate, "visible", false);
            tryCompare(dialerAppDelegate, "visible", false);
            tryCompare(facebookAppDelegate, "visible", true);

            // Bring dash to front. make sure dash and the maximized facebook are visible, the restored one behind is hidden
            dashAppDelegate.focus = true;
            tryCompare(dashAppDelegate, "visible", true);
            tryCompare(dialerAppDelegate, "visible", false);
            tryCompare(facebookAppDelegate, "visible", true);

            // Now focus the dialer app. all 3 should be visible again
            dialerAppDelegate.focus = true;
            tryCompare(dashAppDelegate, "visible", true);
            tryCompare(dialerAppDelegate, "visible", true);
            tryCompare(facebookAppDelegate, "visible", true);

            // Maximize the dialer app. The other 2 should hide
            dialerAppDelegate.maximize();
            tryCompare(dashAppDelegate, "visible", false);
            tryCompare(dialerAppDelegate, "visible", true);
            tryCompare(facebookAppDelegate, "visible", false);
        }

        function test_dropShadow() {
            // start an app, maximize it
            var facebookAppDelegate = startApplication("facebook-webapp");
            facebookAppDelegate.maximize();

            // verify the drop shadow is still not visible
            verify(PanelState.dropShadow == false);

            // start a foreground app, not maximized
            var dialerAppDelegate = startApplication("dialer-app");

            // verify the drop shadow becomes visible
            verify(PanelState.dropShadow == true);

            // close the maximized app
            ApplicationManager.stopApplication("facebook-webapp");

            // verify the drop shadow is gone
            tryCompare(PanelState, "dropShadow", false);
        }

        function test_dashHasNoCloseButton() {
            var dashAppDelegate = startApplication("unity8-dash");
            verify(dashAppDelegate);
            var closeButton = findChild(dashAppDelegate, "closeWindowButton");
            tryCompare(closeButton, "visible", false);
        }
    }
}
