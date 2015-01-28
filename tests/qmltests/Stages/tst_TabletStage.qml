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
    color: "grey"
    width:  tabletStageLoader.width + controls.width
    height: tabletStageLoader.height

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
                maximizedAppTopMargin: units.gu(3) + units.dp(2)
                interactive: true
                shellOrientation: Qt.LandscapeOrientation
                shellPrimaryOrientation: Qt.LandscapeOrientation
                nativeOrientation: Qt.LandscapeOrientation
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
            ApplicationCheckBox {
                id: webbrowserCheckBox
                appId: "webbrowser-app"
            }
            ApplicationCheckBox {
                id: dialerCheckBox
                appId: "dialer-app"
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
            dialerCheckBox.checked = false;
        }

        function waitUntilAppSurfaceShowsUp(appId) {
            var appWindow = findChild(tabletStage, "appWindow_" + appId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function test_tappingSwitchesFocusBetweenStages() {
            webbrowserCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(webbrowserCheckBox.appId);
            var webbrowserApp = ApplicationManager.findApplication(webbrowserCheckBox.appId);
            compare(webbrowserApp.stage, ApplicationInfoInterface.MainStage);
            tryCompare(webbrowserApp.session.surface, "activeFocus", true);

            dialerCheckBox.checked = true;
            waitUntilAppSurfaceShowsUp(dialerCheckBox.appId);
            var dialerApp = ApplicationManager.findApplication(dialerCheckBox.appId);
            compare(dialerApp.stage, ApplicationInfoInterface.SideStage);
            tryCompare(dialerApp.session.surface, "activeFocus", true);
            tryCompare(webbrowserApp.session.surface, "activeFocus", false);

            // Tap on the main stage application and check if the focus
            // has been passed to it.

            var webbrowserWindow = findChild(tabletStage, "appWindow_" + webbrowserApp.appId);
            verify(webbrowserWindow);
            tap(webbrowserWindow);

            tryCompare(dialerApp.session.surface, "activeFocus", false);
            tryCompare(webbrowserApp.session.surface, "activeFocus", true);

            // Now tap on the side stage application and check if the focus
            // has been passed back to it.

            var dialerWindow = findChild(tabletStage, "appWindow_" + dialerApp.appId);
            verify(dialerWindow);
            tap(dialerWindow);

            tryCompare(dialerApp.session.surface, "activeFocus", true);
            tryCompare(webbrowserApp.session.surface, "activeFocus", false);
        }
    }

}
