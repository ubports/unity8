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
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators
import Unity.Test 0.1
import Utils 0.1
import WindowManager 1.0

import ".." // For EdgeBarrierControls
import "../../../qml/Stage"
import "../../../qml/Components"
import "../../../qml/Components/PanelState"
import "../../../qml/ApplicationMenus"

Item {
    id: root
    width:  stageLoader.width + controls.width
    height: stageLoader.height

    property var greeter: { fullyShown: true }

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    Component.onCompleted: {
        ApplicationMenusLimits.screenWidth = Qt.binding( function() { return stageLoader.width; } );
        ApplicationMenusLimits.screenHeight = Qt.binding( function() { return stageLoader.height; } );
        QuickUtils.keyboardAttached = true;
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

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    TopLevelWindowModel {
        id: topSurfaceList
        applicationManager: ApplicationManager
        surfaceManager: sMgr
    }

    Loader {
        id: stageLoader
        x: ((root.width - controls.width) - width) / 2
        y: (root.height - height) / 2
        width: units.gu(160*0.9)
        height: units.gu(100*0.9)

        focus: true

        property bool itemDestroyed: false
        sourceComponent: Component {
            Stage {
                anchors.fill: parent
                background: "/usr/share/backgrounds/warty-final-ubuntu.png"
                focus: true

                Component.onCompleted: {
                    ApplicationManager.startApplication("unity8-dash");
                }
                Component.onDestruction: {
                    stageLoader.itemDestroyed = true;
                }
                orientations: Orientations {}
                applicationManager: ApplicationManager
                topLevelSurfaceList: topSurfaceList
                availableDesktopArea: availableDesktopAreaItem
                interactive: true
                mode: "windowed"

                Item {
                    id: availableDesktopAreaItem
                    anchors.fill: parent
                    anchors.topMargin: PanelState.panelHeight
                }
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

                Label {
                    text: "Right edge push progress"
                }

                Slider {
                    id: rightEdgePushSlider
                    width: parent.width
                    live: true
                    minimumValue: 0.0
                    maximumValue: 1.0
                    onPressedChanged: {
                        if (!pressed) {
                            value = 0;
                        }
                    }
                    Binding { target: stageLoader.item; property: "rightEdgePushProgress"; value: rightEdgePushSlider.value }
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

    StageTestCase {
        id: testCase
        name: "DesktopStage"
        when: windowShown

        stage: stageLoader.status === Loader.Ready ? stageLoader.item : null
        topLevelSurfaceList: topSurfaceList

        function init() {
            // wait until unity8-dash is up and running.
            // it's started automatically by ApplicationManager mock implementation
            tryCompare(ApplicationManager, "count", 1);
            var dashApp = ApplicationManager.findApplication("unity8-dash");
            verify(dashApp);
            tryCompare(dashApp, "state", ApplicationInfoInterface.Running);

            tryCompare(topSurfaceList, "count", 1);
            tryCompareFunction(function(){return topSurfaceList.windowAt(0) != null;}, true);
            topSurfaceList.windowAt(0).activate();
            tryCompare(topSurfaceList, "focusedWindow", topSurfaceList.windowAt(0));
        }

        function cleanup() {
            stageLoader.itemDestroyed = false;
            stageLoader.active = false;

            tryCompare(stageLoader, "status", Loader.Null);
            tryCompare(stageLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(stageLoader, "itemDestroyed", true);

            killApps();

            root.resetGeometry();

            stageLoader.active = true;
            tryCompare(stageLoader, "status", Loader.Ready);
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
            compare(topSurfaceList.focusedWindow, fromDelegate.window);

            var toAppWindow = findChild(toDelegate, "appWindow");
            verify(toAppWindow);
            tap(toAppWindow);
            compare(toDelegate.surface.activeFocus, true);
            compare(topSurfaceList.focusedWindow, toDelegate.window);
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
            compare(topSurfaceList.focusedWindow, fromDelegate.window);

            var toAppWindow = findChild(toDelegate, "appWindow");
            verify(toAppWindow);
            mouseClick(toAppWindow);
            compare(toDelegate.surface.activeFocus, true);
            compare(topSurfaceList.focusedWindow, toDelegate.window);
        }

        function test_tappingOnDecorationFocusesApplication_data() {
            return [
                {tag: "dash to dialer", apps: [ "unity8-dash", "dialer-app", "gmail-webapp"], focusfrom: 0, focusTo: 1 },
                {tag: "dialer to dash", apps: [ "unity8-dash", "dialer-app", "gmail-webapp"], focusfrom: 1, focusTo: 0 }
            ]
        }

        function findDecoratedWindow(surfaceId) {
            var appDelegate = findChild(stage, "appDelegate_" + surfaceId);
            if (!appDelegate) {
                console.warn("Could not find appDelegate for surfaceId="+surfaceId);
                return null;
            }
            return findChild(appDelegate, "decoratedWindow");
        }

        function findWindowDecoration(surfaceId) {
            var appDelegate = findChild(stage, "appDelegate_" + surfaceId);
            if (!appDelegate) {
                console.warn("Could not find appDelegate for surfaceId="+surfaceId);
                return null;
            }
            return findChild(appDelegate, "appWindowDecoration");
        }

        function maximizeDelegate(appDelegate) {
            var maximizeButton = findChild(appDelegate, "maximizeWindowButton");
            verify(maximizeButton);
            mouseClick(maximizeButton);
            tryCompare(appDelegate, "maximized", true);
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
            dialerDelegate.surface.activate();
            tryCompare(dialerDelegate, "focus", true);

            keyClick(Qt.Key_Up, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+Up shortcut to maximize
            tryCompare(dialerDelegate, "maximized", true);
            tryCompare(dialerDelegate, "minimized", false);
        }

        function test_windowMaximizeLeft() {
            var dialerDelegate = startApplication("dialer-app");
            startApplication("camera-app");

            tryCompareFunction(function(){ return dialerDelegate.surface !== null; }, true);
            dialerDelegate.surface.activate();
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
            dialerDelegate.surface.activate();
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
            dialerDelegate.surface.activate();
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

            var stagePriv = findInvisibleChild(stage, "DesktopStagePrivate");
            tryCompare(stagePriv, "focusedAppDelegate", dialerDelegate);

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
            tryCompare(dialerDelegate, "windowState", WindowStateStorage.WindowStateRestored);
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
            tryCompare(dialerDelegate, "windowState", WindowStateStorage.WindowStateRestored);
        }

        function test_smashCursorKeys() {
            var apps = ["dialer-app", "gmail-webapp"];
            apps.forEach(startApplication);
            verify(topSurfaceList.count == 3);
            keyClick(Qt.Key_D, Qt.MetaModifier|Qt.ControlModifier); // Ctrl+Super+D shortcut to minimize all
            tryCompare(topSurfaceList, "focusedWindow", null); // verify no window is focused

            // now try pressing all 4 arrow keys + ctrl + meta
            keyClick(Qt.Key_Up | Qt.Key_Down | Qt.Key_Left | Qt.Key_Right, Qt.MetaModifier|Qt.ControlModifier); // smash it!!!
            tryCompare(topSurfaceList, "focusedWindow", null); // verify still no window is focused
        }

        function test_minimizeApplicationHidesSurface() {
            compare(topSurfaceList.applicationAt(0).appId, "unity8-dash");
            var dashSurface = topSurfaceList.surfaceAt(0);
            var dashSurfaceId = topSurfaceList.idAt(0);

            var decoratedWindow = findDecoratedWindow(dashSurfaceId);
            verify(decoratedWindow);

            var minimizeButton = findChild(decoratedWindow, "minimizeWindowButton");
            verify(minimizeButton);

            tryCompare(dashSurface, "exposed", true);
            mouseClick(minimizeButton);
            tryCompare(dashSurface, "exposed", false);
        }

        function test_maximizeApplicationHidesSurfacesBehindIt() {
            var dashDelegate = startApplication("unity8-dash");
            var dialerDelegate = startApplication("dialer-app");
            var gmailDelegate = startApplication("gmail-webapp");

            // maximize without raising
            dialerDelegate.requestMaximize();
            tryCompare(dialerDelegate, "visuallyMaximized", true);

            tryCompare(dashDelegate.surface, "exposed", false);
            compare(gmailDelegate.surface.exposed, true);

            // restore without raising
            dialerDelegate.requestRestore();
            tryCompare(dashDelegate.surface, "exposed", true);
            compare(gmailDelegate.surface.exposed, true);
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

            wait(2000)

            var gmailMaximizeButton = findChild(gmailDelegate, "maximizeWindowButton");
            verify(gmailMaximizeButton);
            mouseClick(gmailMaximizeButton);

            tryCompare(dialerDelegate, "visuallyMaximized", true);
            tryCompare(gmailDelegate, "visuallyMaximized", true);

            tryCompare(dashApp.surfaceList.get(0), "exposed", false);
            tryCompare(dialerApp.surfaceList.get(0), "exposed", false);
            tryCompare(mapApp.surfaceList.get(0), "exposed", false);

            ApplicationManager.stopApplication("gmail-webapp");
            wait(2000)

            tryCompare(mapApp.surfaceList.get(0), "exposed", true);
            tryCompare(dialerApp.surfaceList.get(0), "exposed", true);
            tryCompare(dashApp.surfaceList.get(0), "exposed", false); // still occluded by maximised dialer
        }

        function test_maximisedAppStaysVisibleWhenAppStarts() {
            var dashDelegate = startApplication("unity8-dash");

            maximizeDelegate(dashDelegate);

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
            maximizeDelegate(facebookAppDelegate);
            tryCompare(dashAppDelegate, "visible", false);
            tryCompare(dialerAppDelegate, "visible", false);
            tryCompare(facebookAppDelegate, "visible", true);

            // Bring dash to front. make sure dash and the maximized facebook are visible, the restored one behind is hidden
            dashAppDelegate.activate();
            tryCompare(dashAppDelegate, "visible", true);
            tryCompare(dialerAppDelegate, "visible", false);
            tryCompare(facebookAppDelegate, "visible", true);

            // Now focus the dialer app. all 3 should be visible again
            dialerAppDelegate.activate();
            tryCompare(dashAppDelegate, "visible", true);
            tryCompare(dialerAppDelegate, "visible", true);
            tryCompare(facebookAppDelegate, "visible", true);

            // Maximize the dialer app. The other 2 should hide
            maximizeDelegate(dialerAppDelegate);
            tryCompare(dashAppDelegate, "visible", false);
            tryCompare(dialerAppDelegate, "visible", true);
            tryCompare(facebookAppDelegate, "visible", false);
        }

        function test_dropShadow() {
            // start an app, maximize it
            var facebookAppDelegate = startApplication("facebook-webapp");
            maximizeDelegate(facebookAppDelegate);

            // verify the drop shadow is still not visible
            verify(PanelState.dropShadow == false);

            // start a foreground app, not maximized
            var dialerAppDelegate = startApplication("dialer-app");

            // verify the drop shadow becomes visible
            tryCompareFunction(function() { return PanelState.dropShadow; }, true);

            // close the maximized app
            ApplicationManager.stopApplication("facebook-webapp");

            // verify the drop shadow is gone
            tryCompare(PanelState, "dropShadow", false);
        }

        function test_threeFingerTapShowsWindowControls_data() {
            return [
                { tag: "1 finger", touchIds: [0], result: false },
                { tag: "2 finger", touchIds: [0, 1], result: false },
                { tag: "3 finger", touchIds: [0, 1, 2], result: true },
                { tag: "4 finger", touchIds: [0, 1, 2, 3], result: false },
            ];
        }

        function test_threeFingerTapShowsWindowControls(data) {
            var facebookAppDelegate = startApplication("facebook-webapp");
            verify(facebookAppDelegate);
            var overlay = findChild(facebookAppDelegate, "windowControlsOverlay");
            verify(overlay);

            multiTouchTap(data.touchIds, facebookAppDelegate);
            tryCompare(overlay, "visible", data.result);

            if (data.result) { // if shown, try to hide it by clicking outside
                mouseClick(stage);
                tryCompare(overlay, "visible", false);
            }
        }

        function test_windowControlsOverlayMaximizeButtonReachable() {
            var facebookAppDelegate = startApplication("facebook-webapp");
            verify(facebookAppDelegate);
            var overlay = findChild(facebookAppDelegate, "windowControlsOverlay");
            verify(overlay);

            multiTouchTap([0, 1, 2], facebookAppDelegate);
            tryCompare(overlay, "visible", true);

            var maxButton = findChild(facebookAppDelegate, "maximizeWindowButton");
            tryCompare(maxButton, "visible", true);
            wait(700); // there's a lot of behaviors on different decoration elements, make sure they're all settled
            mouseClick(maxButton);
            tryCompare(facebookAppDelegate, "maximized", true);
        }

        function test_hideMaximizeButtonWhenSizeConstrained() {
            var dialerDelegate = startApplication("dialer-app");

            var dialerMaximizeButton = findChild(dialerDelegate, "maximizeWindowButton");
            tryCompare(dialerMaximizeButton, "visible", true);

            // add size restrictions, smaller than our stage
            dialerDelegate.surface.setMaximumWidth(40);
            dialerDelegate.surface.setMaximumHeight(30);
            tryCompare(dialerMaximizeButton, "visible", false);

            // try double clicking the decoration, shouldn't maximize it
            var sizeBefore = Qt.size(dialerDelegate.width, dialerDelegate.height);
            var deco = findChild(dialerDelegate, "appWindowDecoration");
            verify(deco);
            // deco.width - units.gu(1) to make sure we're outside the "menu" area of the decoration
            mouseMove(deco, deco.width - units.gu(1), deco.height/2);
            var menuBarLoader = findChild(deco, "menuBarLoader");
            tryCompare(menuBarLoader.item, "visible", true);
            mouseDoubleClick(deco, deco.width - units.gu(1), deco.height/2)
            expectFail("", "Double click should not maximize in a size restricted window");
            tryCompareFunction(function() {
                    var sizeAfter = Qt.size(dialerDelegate.width, dialerDelegate.height);
                    return sizeAfter.width > sizeBefore.width && sizeAfter.height > sizeBefore.height;
                },
                true
            );

            // remove restrictions, the maximize button should again be visible
            dialerDelegate.surface.setMaximumWidth(0);
            dialerDelegate.surface.setMaximumHeight(0);
            tryCompare(dialerMaximizeButton, "visible", true);
        }

        function test_doubleClickMaximizes() {
            var dialerDelegate = startApplication("dialer-app");

            var dialerMaximizeButton = findChild(dialerDelegate, "maximizeWindowButton");
            tryCompare(dialerMaximizeButton, "visible", true);

            // try double clicking the decoration, should maximize it
            var sizeBefore = Qt.size(dialerDelegate.width, dialerDelegate.height);
            var deco = findChild(dialerDelegate, "appWindowDecoration");
            verify(deco);
            // deco.width - units.gu(1) to make sure we're outside the "menu" area of the decoration
            mouseMove(deco, deco.width - units.gu(1), deco.height/2);
            var menuBarLoader = findChild(deco, "menuBarLoader");
            tryCompare(menuBarLoader.item, "visible", true);
            mouseDoubleClick(deco, deco.width - units.gu(1), deco.height/2);
            tryCompareFunction(function() {
                    var sizeAfter = Qt.size(dialerDelegate.width, dialerDelegate.height);
                    return sizeAfter.width > sizeBefore.width && sizeAfter.height > sizeBefore.height;
                },
                true
            );
        }

        function test_canMoveWindowWithLeftMouseButtonOnly_data() {
            return [
                {tag: "left mouse button", button: Qt.LeftButton },
                {tag: "right mouse button", button: Qt.RightButton },
                {tag: "middle mouse button", button: Qt.MiddleButton }
            ]
        }

        function test_canMoveWindowWithLeftMouseButtonOnly(data) {
            var appDelegate = startApplication("dialer-app");
            verify(appDelegate);

            var posBefore = Qt.point(appDelegate.x, appDelegate.y);

            mouseDrag(appDelegate, appDelegate.width / 2, units.gu(1), 0, appDelegate.height / 2, data.button, Qt.NoModifier, 200)

            var posAfter = Qt.point(appDelegate.x, appDelegate.y);

            tryCompareFunction(function(){return posBefore == posAfter;}, data.button !== Qt.LeftButton ? true : false);
        }

        function test_spreadDisablesWindowDrag() {
            var appDelegate = startApplication("dialer-app");
            verify(appDelegate);
            var decoration = findChild(appDelegate, "appWindowDecoration");
            verify(decoration);

            // grab the decoration
            mousePress(decoration);

            // enter the spread
            keyPress(Qt.Key_W, Qt.MetaModifier)
            tryCompare(stage, "state", "spread");

            // try to drag the window
            mouseMove(decoration, 10, 10, 200);

            // verify it's not moving even before we release the decoration drag
            tryCompare(appDelegate, "dragging", false);

            // cleanup
            mouseRelease(decoration);
            keyRelease(Qt.Key_W, Qt.MetaModifier);
            stage.closeSpread();
            tryCompare(stage, "state", "windowed");
        }

        // regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1627281
        function test_doubleTapToMaximizeWindow() {
            var dialerAppDelegate = startApplication("dialer-app");
            verify(dialerAppDelegate);
            var decoration = findChild(dialerAppDelegate, "appWindowDecoration");
            verify(decoration);

            // simulate a double tap, with a slight erroneous move in between those 2 taps
            tap(decoration); tap(decoration);
            touchMove(decoration, decoration.width/2, decoration.height/2 - 10);
            touchRelease(decoration);
            waitUntilTransitionsEnd(dialerAppDelegate);
            waitUntilTransitionsEnd(stage);

            tryCompare(dialerAppDelegate, "maximized", true);
        }

        function test_saveRestoreSize() {
            var originalWindowCount = topSurfaceList.count;
            var appDelegate = startApplication("dialer-app");
            compare(topSurfaceList.count, originalWindowCount + 1);

            var initialWindowX = appDelegate.windowedX;
            var initialWindowY = appDelegate.windowedY;
            var initialWindowWidth = appDelegate.width
            var initialWindowHeight = appDelegate.height

            var resizeDelta = units.gu(5)
            var startDragX = initialWindowX + initialWindowWidth + 1
            var startDragY = initialWindowY + initialWindowHeight + 1
            mouseFlick(root, startDragX, startDragY, startDragX + resizeDelta, startDragY + resizeDelta, true, true, units.gu(.5), 10);

            tryCompare(appDelegate, "width", initialWindowWidth + resizeDelta);
            tryCompare(appDelegate, "height", initialWindowHeight + resizeDelta);

            // Close the window and restart the application
            var closeButton = findChild(appDelegate, "closeWindowButton");
            appDelegate = null;
            verify(closeButton);
            mouseClick(closeButton);
            tryCompare(topSurfaceList, "count", originalWindowCount);
            wait(100); // plus some spare room
            appDelegate = startApplication("dialer-app");

            // Make sure its size is again the same as before
            tryCompare(appDelegate, "width", initialWindowWidth + resizeDelta);
            tryCompare(appDelegate, "height", initialWindowHeight + resizeDelta);
        }

        function test_saveRestoreMaximized() {
            var originalWindowCount = topSurfaceList.count;
            var appDelegate = startApplication("dialer-app");
            compare(topSurfaceList.count, originalWindowCount + 1);

            var initialWindowX = appDelegate.windowedX;
            var initialWindowY = appDelegate.windowedY;

            var moveDelta = units.gu(5);

            appDelegate.windowedX = initialWindowX + moveDelta
            appDelegate.windowedY = initialWindowY + moveDelta

            // Now change the state to maximized. The window should not keep updating the stored values
            maximizeAppDelegate(appDelegate);

            // Close the window and restart the application
            appDelegate.close();
            tryCompare(topSurfaceList, "count", originalWindowCount);
            wait(100); // plus some spare room
            appDelegate = startApplication("dialer-app");

            // Make sure it's again where we left it in normal state before destroying
            tryCompare(appDelegate, "windowedX", initialWindowX + moveDelta)
            tryCompare(appDelegate, "windowedY", initialWindowY + moveDelta)

            // Make sure maximize() has been called after restoring
            tryCompare(appDelegate, "state", "maximized")

            // clean up
            // click on restore button (same one as maximize)
            var maximizeButton = findChild(appDelegate, "maximizeWindowButton");
            mouseClick(maximizeButton);
        }

        function test_grabbingCursorOnDecorationPress() {
            var appDelegate = startApplication("dialer-app");
            verify(appDelegate);
            var decoration = findChild(appDelegate, "appWindowDecoration");
            verify(decoration);

            mousePress(decoration, decoration.width/2, decoration.height/2, Qt.LeftButton);
            tryCompare(Mir, "cursorName", "grabbing");

            mouseMove(decoration, decoration.width/2 + 1, decoration.height/2 + 1);
            tryCompare(Mir, "cursorName", "grabbing");

            mouseRelease(decoration);
            tryCompare(Mir, "cursorName", "");
        }

        function test_menuPositioning_data() {
            return [
                {tag: "good",
                    windowPosition: Qt.point(units.gu(10),  units.gu(10))
                },
                {tag: "collides right",
                    windowPosition: Qt.point(units.gu(100), units.gu(10)),
                    minimumXDifference: units.gu(8)
                },
                {tag: "collides bottom",
                    windowPosition: Qt.point(units.gu(10),  units.gu(80)),
                    minimumYDifference: units.gu(7)
                },
            ]
        }

        function test_menuPositioning(data) {
            var appDelegate = startApplication("dialer-app");
            appDelegate.windowedX = data.windowPosition.x;
            appDelegate.windowedY = data.windowPosition.y;

            var menuItem = findChild(appDelegate, "menuBar-item3");
            menuItem.show();

            var menu = findChild(appDelegate, "menuBar-item3-menu");
            tryCompare(menu, "visible", true);

            var normalPositioningX = menuItem.x - units.gu(1);
            var normalPositioningY = menuItem.height;

            // We do this fuzzy checking because otherwise we would be duplicating the code
            // that calculates the coordinates and any bug it may have, what we want is really
            // to check that on collision with the border the menu is shifted substantially
            if (data.minimumXDifference) {
                verify(menu.x < normalPositioningX - data.minimumXDifference);
            } else {
                compare(menu.x, normalPositioningX);
            }

            if (data.minimumYDifference) {
                verify(menu.y < normalPositioningY - data.minimumYDifference);
            } else {
                compare(menu.y, normalPositioningY);
            }
        }

        function test_submenuPositioning_data() {
            return [
                {tag: "good",
                    windowPosition: Qt.point(units.gu(10),  units.gu(10))
                },
                {tag: "collides right",
                    windowPosition: Qt.point(units.gu(100), units.gu(10)),
                    minimumXDifference: units.gu(35)
                },
                {tag: "collides bottom",
                    windowPosition: Qt.point(units.gu(10),  units.gu(80)),
                    minimumYDifference: units.gu(8)
                },
            ]
        }

        function test_submenuPositioning(data) {
            var appDelegate = startApplication("dialer-app");
            appDelegate.windowedX = data.windowPosition.x;
            appDelegate.windowedY = data.windowPosition.y;

            var menuItem = findChild(appDelegate, "menuBar-item3");
            menuItem.show();

            var menu = findChild(appDelegate, "menuBar-item3-menu");
            menuItem = findChild(menu, "menuBar-item3-menu-item3-actionItem");
            tryCompare(menuItem, "visible", true);
            mouseMove(menuItem);
            mouseClick(menuItem);

            menu = findChild(appDelegate, "menuBar-item3-menu-item3-menu");

            var normalPositioningX = menuItem.width;
            var normalPositioningY = menuItem.parent.y;

            // We do this fuzzy checking because otherwise we would be duplicating the code
            // that calculates the coordinates and any bug it may have, what we want is really
            // to check that on collision with the border the menu is shifted substantially
            if (data.minimumXDifference) {
                verify(menu.x < normalPositioningX - data.minimumXDifference);
            } else {
                compare(menu.x, normalPositioningX);
            }

            if (data.minimumYDifference) {
                verify(menu.y < normalPositioningY - data.minimumYDifference);
            } else {
                compare(menu.y, normalPositioningY);
            }
        }

        function test_menuDoubleClickNoMaximizeWindowBehind() {
            var appDelegate1 = startApplication("dialer-app");
            var appDelegate2 = startApplication("gmail-webapp");

            // Open menu
            var menuItem = findChild(appDelegate2, "menuBar-item3");
            menuItem.show();
            var menu = findChild(appDelegate2, "menuBar-item3-menu");
            menuItem = findChild(menu, "menuBar-item3-menu-item3-actionItem");
            tryCompare(menuItem, "visible", true);

            // Place the other application window decoration under the menu
            var pos = menuItem.mapToItem(null, menuItem.width / 2, menuItem.height / 2);
            appDelegate1.windowedX = pos.x - appDelegate1.width / 2;
            appDelegate1.windowedY = pos.y - units.gu(1);

            var previousWindowState = appDelegate1.windowState;

            mouseMove(menuItem);
            mouseDoubleClickSequence(menuItem);

            expectFail("", "Double clicking a menu should not change the window below");
            tryCompareFunction(function() { return appDelegate1.windowState != previousWindowState; }, true);
        }

        function test_openMenuEatsHoverOutsideIt() {
            var appDelegate = startApplication("gmail-webapp");

            var wd = findChild(appDelegate, "appWindowDecoration");
            var closeButton = findChild(wd, "closeWindowButton");

            // Open menu
            var menuItem = findChild(appDelegate, "menuBar-item3");
            menuItem.show();
            var menu = findChild(appDelegate, "menuBar-item3-menu");
            tryCompare(menu, "visible", true);

            mouseMove(closeButton, closeButton.width/2, closeButton.height/2);
            expectFail("", "Hovering the window controls should be ignored when the menu is open");
            tryCompare(closeButton, "containsMouse", true);
        }

        function test_windowControlsTouchInteractionWithMenu() {
            var appDelegate = startApplication("gmail-webapp");

            var wd = findChild(appDelegate, "appWindowDecoration");
            var maxButton = findChild(wd, "maximizeWindowButton");
            var menuBarLoader = findChild(wd, "menuBarLoader");
            var menuNav = findInvisibleChild(menuBarLoader, "d");

            // make the menubar active and visible, select first item
            menuBarLoader.active = true;
            menuNav.select(0);
            tryCompare(menuBarLoader.item, "visible", true);

            // verify the maximized button can still be tapped
            tap(maxButton);
            tryCompare(appDelegate, "state", "maximized");
        }

        function test_childWindowGetsActiveFocus() {
            var appDelegate = startApplication("kate");
            appDelegate.surface.openDialog(units.gu(5), units.gu(5), units.gu(30), units.gu(30));
            var childWindow = findChild(appDelegate, "childWindow");
            verify(childWindow);
            var surfaceItem = findChild(childWindow, "surfaceItem");
            verify(surfaceItem);
            tryCompare(surfaceItem, "activeFocus", true);
        }
    }
}
