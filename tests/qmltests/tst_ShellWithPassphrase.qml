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

import QtQuick 2.3
import Ubuntu.Components 1.1
import QtTest 1.0
import LightDM 0.1 as LightDM
import Unity.Application 0.1
import Unity.Test 0.1 as UT

import "../../qml"

Item {
    id: root
    width: contentRow.width
    height: contentRow.height

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDM.Greeter.mockMode = "single-passphrase";
        LightDM.Users.mockMode = "single-passphrase";
        shellLoader.active = true;
    }

    QtObject {
        id: applicationArguments

        function hasGeometry() {
            return false;
        }

        function width() {
            return 0;
        }

        function height() {
            return 0;
        }
    }

    Row {
        id: contentRow

        Loader {
            id: shellLoader
            active: false

            width: units.gu(40)
            height: units.gu(71)

            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    property string indicatorProfile: "phone"

                    Component.onDestruction: {
                        shellLoader.itemDestroyed = true;
                    }
                }
            }
        }

        Rectangle {
            color: "white"
            width: units.gu(30)
            height: shellLoader.height

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)
                Button {
                    anchors { left: parent.left; right: parent.right }
                    text: "Show Greeter"
                    onClicked: LightDM.Greeter.showGreeter()
                }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "ShellWithPassphrase"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null

        function init() {
            tryCompare(shell, "enabled", true); // will be enabled when greeter is all ready
        }

        function cleanup() {
            tryCompare(shell, "enabled", true); // make sure greeter didn't leave us in disabled state

            shellLoader.itemDestroyed = false;
            shellLoader.active = false;
            tryCompare(shellLoader, "status", Loader.Null);
            tryCompare(shellLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(shellLoader, "itemDestroyed", true);

            killApps();
            LightDM.Greeter.authenticate(""); // reset greeter

            // reload our test subject to get it in a fresh state once again
            shellLoader.active = true;
            tryCompare(shellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(shellLoader.item);
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0;
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1);
        }
    }
}
