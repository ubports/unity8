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

import "../../../qml/Stages"

Rectangle {
    id: root
    color: "darkblue"
    width:  desktopStageLoader.width + controls.width
    height: desktopStageLoader.height

    QtObject {
        id: fakeWindowStateStorage

        property var storedGeom: [
            ["unity8-dash", Qt.rect(units.gu(2), units.gu(2), units.gu(50), units.gu(50))],
            ["webbrowser-app", Qt.rect(units.gu(60), units.gu(2), units.gu(50), units.gu(50))]
        ]

        function saveGeometry(windowId, geometry) {
            for (var i = 0; i < storedGeom.length; ++i) {
                if (storedGeom[i][0] === windowId) {
                    storedGeom[i][1] = geometry;
                    return;
                }
            }
            // if new
            storedGeom[storedGeom.length] = [windowId, geometry];
        }
        function getGeometry(windowId, defaultGeometry) {
            for (var i = 0; i < storedGeom.length; ++i) {
                if (storedGeom[i][0] === windowId) {
                    return storedGeom[i][1];
                }
            }
            return defaultGeometry;
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
                anchors.fill: parent
                windowStateStorage: fakeWindowStateStorage
                Component.onDestruction: {
                    desktopStageLoader.itemDestroyed = true;
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

        function init() {
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

        function rectsIntersect(aLocal, bLocal) {

            var a = aLocal.mapToItem(null, 0, 0, aLocal.width, aLocal.height);
            var b = bLocal.mapToItem(null, 0, 0, bLocal.width, bLocal.height);

            return !((a.y+a.height) < b.y
                   || a.y > (b.y+b.height)
                   || (a.x+a.width) < b.x
                   || a.x > (b.x+b.width));
        }

        function test_tappingOnWindowChangesFocusedApp() {
            ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppSurfaceShowsUp("webbrowser-app");

            var webbrowserWindow = findChild(desktopStage, "appWindow_webbrowser-app");
            verify(webbrowserWindow);
            var dashWindow = findChild(desktopStage, "appWindow_unity8-dash");
            verify(dashWindow);

            // some sanity check
            compare(rectsIntersect(dashWindow, webbrowserWindow), false);

            tap(dashWindow);
            compare(dashWindow.application.session.surface.activeFocus, true);

            tap(webbrowserWindow);
            compare(webbrowserWindow.application.session.surface.activeFocus, true);
        }

        function test_tappingOnWindowTitleChangesFocusedApp() {
            ApplicationManager.startApplication("webbrowser-app");
            waitUntilAppSurfaceShowsUp("webbrowser-app");

            var webbrowserWindow = findChild(desktopStage, "decoratedWindow_webbrowser-app");
            verify(webbrowserWindow);
            var webbrowserWindowTitle = findChild(webbrowserWindow, "windowDecorationTitle");
            verify(webbrowserWindowTitle);
            var dashWindow = findChild(desktopStage, "decoratedWindow_unity8-dash");
            verify(dashWindow);
            var dashWindowTitle = findChild(dashWindow, "windowDecorationTitle");
            verify(dashWindowTitle);

            // some sanity check
            compare(rectsIntersect(dashWindow, webbrowserWindow), false);

            tap(dashWindowTitle);
            compare(dashWindow.application.session.surface.activeFocus, true);

            tap(webbrowserWindowTitle);
            compare(webbrowserWindow.application.session.surface.activeFocus, true);
        }
    }
}
