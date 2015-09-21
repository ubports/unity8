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

import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Unity.Application 0.1
import Unity.Test 0.1
import Utils 0.1

import "../../../qml/Stages"

Item {
    id: root
    width:  desktopStageLoader.width + controls.width
    height: desktopStageLoader.height

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    Component.onCompleted: {
        // ensures apps which are tested decorations are in view.
        WindowStateStorage.geometry = {
            'unity8-dash': Qt.rect(0, units.gu(3), units.gu(50), units.gu(40)),
            'dialer-app': Qt.rect(units.gu(51), units.gu(3), units.gu(50), units.gu(40)),
            'camera-app': Qt.rect(0, units.gu(44), units.gu(50), units.gu(40)),
        }
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
                color: "darkblue"
                anchors.fill: parent
                Component.onDestruction: {
                    desktopStageLoader.itemDestroyed = true;
                }
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
            Repeater {
                model: ApplicationManager.availableApplications
                ApplicationCheckBox {
                    appId: modelData
                }
            }
        }
    }

    UnityTestCase {
        id: testCase
        name: "DesktopStage"
        when: windowShown

        property Item desktopStage: desktopStageLoader.status === Loader.Ready ? desktopStageLoader.item : null

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

            killAllRunningApps();

            desktopStageLoader.active = true;
            tryCompare(desktopStageLoader, "status", Loader.Ready);
        }

        function killAllRunningApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1)
        }

        function waitUntilAppSurfaceShowsUp(appId) {
            var appWindow = findChild(desktopStage, "appWindow_" + appId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function startApplication(appId) {
            var app = ApplicationManager.findApplication(appId);
            if (!app) {
                app = ApplicationManager.startApplication(appId);
            }
            verify(app);
            waitUntilAppSurfaceShowsUp(appId);
            verify(app.session.surface);
            return app;
        }

        function test_appFocusSwitch_data() {
            return [
                {tag: "dash to dialer", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 0, focusTo: 1 },
                {tag: "dialer to dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 1, focusTo: 0 },
            ]
        }

        function test_appFocusSwitch(data) {
            var i;
            for (i = 0; i < data.apps.length; i++) {
                startApplication(data.apps[i]);
            }

            ApplicationManager.requestFocusApplication(data.apps[data.focusfrom]);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusfrom]).session.surface, "activeFocus", true);

            ApplicationManager.requestFocusApplication(data.apps[data.focusTo]);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusTo]).session.surface, "activeFocus", true);
        }

        function test_tappingOnWindowChangesFocusedApp_data() {
            return [
                {tag: "dash to dialer", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 0, focusTo: 1 },
                {tag: "dialer to dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 1, focusTo: 0 },
            ]
        }

        function test_tappingOnWindowChangesFocusedApp(data) {
            var i;
            for (i = 0; i < data.apps.length; i++) {
                startApplication(data.apps[i]);
            }
            var fromAppId = data.apps[data.focusfrom];
            var toAppId = data.apps[data.focusTo]

            var fromAppWindow = findChild(desktopStage, "appWindow_" + fromAppId);
            verify(fromAppWindow);
            tap(fromAppWindow);
            compare(fromAppWindow.application.session.surface.activeFocus, true);
            compare(ApplicationManager.focusedApplicationId, fromAppId);

            var toAppWindow = findChild(desktopStage, "appWindow_" + toAppId);
            verify(toAppWindow);
            tap(toAppWindow);
            compare(toAppWindow.application.session.surface.activeFocus, true);
            compare(ApplicationManager.focusedApplicationId, toAppId);
        }

        function test_tappingOnDecorationFocusesApplication_data() {
            return [
                {tag: "dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 0, focusTo: 1 },
                {tag: "dash", apps: [ "unity8-dash", "dialer-app", "camera-app" ], focusfrom: 1, focusTo: 0 },
            ]
        }

        function test_tappingOnDecorationFocusesApplication(data) {
            var i;
            for (i = 0; i < data.apps.length; i++) {
                startApplication(data.apps[i]);
            }

            var fromAppDecoration = findChild(desktopStage, "appWindowDecoration_" + data.apps[data.focusfrom]);
            verify(fromAppDecoration);
            tap(fromAppDecoration);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusfrom]).session.surface, "activeFocus", true);

            var toAppDecoration = findChild(desktopStage, "appWindowDecoration_" + data.apps[data.focusTo]);
            verify(toAppDecoration);
            tap(toAppDecoration);
            tryCompare(ApplicationManager.findApplication(data.apps[data.focusTo]).session.surface, "activeFocus", true);
        }
    }
}
