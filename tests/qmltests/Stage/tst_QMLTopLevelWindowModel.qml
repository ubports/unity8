/*
 * Copyright 2014-2016 Canonical Ltd.
 * Copyright 2019 UBports Foundation
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
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Components"
import "../../../qml/Stage"
import Lomiri.Components 1.3
import Unity.Application 0.1
import WindowManager 1.0

Item {
    id: root
    width: units.gu(70)
    height: units.gu(70)

    property var greeter: { fullyShown: true }

    readonly property var topLevelSurfaceList: {
        if (!WMScreen.currentWorkspace) return null;
        return stage.temporarySelectedWorkspace ? stage.temporarySelectedWorkspace.windowModel : WMScreen.currentWorkspace.windowModel
    }

    ApplicationMenuDataLoader {
        id: appMenuData
    }

    Loader {
        id: loader
        active: true;

        sourceComponent: Stage {
            id: stage
            anchors { fill: parent; rightMargin: units.gu(30) }
            focus: true
            dragAreaWidth: units.gu(2)
            allowInteractivity: true
            shellOrientation: Qt.PortraitOrientation
            orientations: Orientations {}
            applicationManager: ApplicationManager
            mode: "staged"
            topLevelSurfaceList: root.topLevelSurfaceList
            availableDesktopArea: availableDesktopAreaItem
            Item {
                id: availableDesktopAreaItem
                anchors.fill: parent
            }
        }
    }

    Flickable {
        contentHeight: controlRect.height

        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.right: root.right
        width: units.gu(30)
        Rectangle {
            id: controlRect
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height + units.gu(2)
            color: "darkGrey"
            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)
                Repeater {
                    model: ApplicationManager.availableApplications
                    ApplicationCheckBox { appId: modelData }
                }
            }
        }
    }

    property alias stage: loader.item
    property var tlwm: loader.item.topLevelSurfaceList

    UT.UnityTestCase {
        id: testCase
        name: "QMLTopLevelWindowModel"
        when: windowShown

        function init() {
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
            verify(stage);
            verify(tlwm);
            waitForRendering(stage);
        }

        function cleanup() {
            killApps();
            loader.active = false;
        }

        function findAppWindowForSurfaceId(surfaceId) {
            var delegateObjectName = "appDelegate_" + surfaceId;
            var spreadDelegate = findChild(stage, delegateObjectName);
            if (!spreadDelegate) {
                console.warn("Failed to find " + delegateObjectName + " in stage");
                return null;
            }
            var appWindow = findChild(spreadDelegate, "appWindow");
            return appWindow;
        }

        // Waits until ApplicationWindow has moved from showing a splash screen to displaying
        // the application surface.
        function waitUntilAppSurfaceShowsUp(surfaceId) {
            var appWindow = findAppWindowForSurfaceId(surfaceId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function addApps(count) {
            if (count == undefined) count = 1;
            for (var i = 0; i < count; i++) {
                var startingAppId = ApplicationManager.availableApplications[ApplicationManager.count];
                var appSurfaceId = tlwm.nextId;
                var app = ApplicationManager.startApplication(startingAppId)
                tryCompare(app, "state", ApplicationInfoInterface.Running)
                waitUntilAppSurfaceShowsUp(appSurfaceId);
                waitForRendering(stage)
                tryCompare(ApplicationManager, "focusedApplicationId", startingAppId)
            }
        }

        /*
            Ensure that closing a surface while rootFocus is off focuses the
            next available surface when rootFocus is given back.

            Regression test for https://github.com/ubports/unity8/issues/234

            This cannot be tested in tst_TopLevelWindowModel.cpp, the mocks for
            it are not advanced enough.
        */
        function test_closeLastFocusedApp()
        {
            var dialerApp = ApplicationManager.startApplication("dialer-app");
            var webbrowserSurfaceId = tlwm.nextId;
            var webbrowserApp  = ApplicationManager.startApplication("morph-browser");
            waitUntilAppSurfaceShowsUp(webbrowserSurfaceId);

            tlwm.rootFocus = false;

            ApplicationManager.stopApplication(webbrowserApp.appId);
            // It should be gone soon
            tryCompareFunction(function() { return tlwm.indexForId(webbrowserSurfaceId); }, -1);

            tlwm.rootFocus = true;
            compare(dialerApp.focused, true);
        }

        /*
            Ensure that the newly-opened window from an already-opened app will
            be focused in addition to being on top.
         */
        function test_focusNewWindowFromOpenedApp()
        {
            var firstWindowSurfaceId = tlwm.nextId;
            var webbrowserApp = ApplicationManager.startApplication("morph-browser");
            waitUntilAppSurfaceShowsUp(firstWindowSurfaceId);

            // Create the second window
            var secondWindowSurfaceId = tlwm.nextId;
            webbrowserApp.createSurface();

            var topWindow = tlwm.windowAt(0);
            compare(topWindow.id, secondWindowSurfaceId, "The top window is not the second window.");
            compare(topWindow.focused, true, "The second window isn't focused.");
        }
    }
}
