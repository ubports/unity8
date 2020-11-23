/*
 * Copyright 2014-2016 Canonical Ltd.
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
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Stage"
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Application 0.1

Rectangle {
    color: "red"
    id: root
    width: units.gu(70)
    height: units.gu(70)

    Component.onCompleted: {
        root.fakeApplication = ApplicationManager.add("gallery-app");
        root.fakeApplication.manualSurfaceCreation = true;
        applicationWindowLoader.item.application = root.fakeApplication;
    }
    property QtObject fakeApplication: null

    Loader {
        id: applicationWindowLoader
        focus: true
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: units.gu(40)
        property bool itemDestroyed: false
        sourceComponent: Component {
            ApplicationWindow {
                anchors.fill: parent
                surfaceOrientationAngle: 0
                interactive: true
                focus: true
                requestedWidth: width
                requestedHeight: height
                Component.onDestruction: {
                    applicationWindowLoader.itemDestroyed = true;
                }
            }
        }
    }

    Rectangle {
        color: "white"
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: applicationWindowLoader.right
            right: parent.right
        }

        ColumnLayout {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: surfaceCheckbox
                    checked: false;
                    activeFocusOnPress: false
                    onCheckedChanged: {
                        if (applicationWindowLoader.status !== Loader.Ready)
                            return;

                        if (checked) {
                            root.fakeApplication.createSurface();
                            applicationWindowLoader.item.surface = root.fakeApplication.surfaceList.get(0);
                        } else {
                            if (applicationWindowLoader.item.surface) {
                                applicationWindowLoader.item.surface.setLive(false);
                            }
                        }
                    }
                }
                Label {
                    text: "Surface"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            RowLayout {
                property var promptSurfaceList: root.fakeApplication ? root.fakeApplication.promptSurfaceList : null
                Button {
                    enabled: root.fakeApplication && root.fakeApplication.promptSurfaceList.count > 0
                    activeFocusOnPress: false
                    text: "Remove"
                    onClicked: { root.fakeApplication.promptSurfaceList.get(0).close(); }
                }

                Button {
                    enabled: root.fakeApplication
                    activeFocusOnPress: false
                    text: "Add Prompt Surface"
                    onClicked: { root.fakeApplication.createPromptSurface(); }
                }
            }

            ListItem.ItemSelector {
                id: appStateSelector
                activeFocusOnPress: false
                anchors { left: parent.left; right: parent.right }
                text: "Application state"
                model: ["Starting",
                        "Running",
                        "Suspended",
                        "Stopped"]
                property int selectedApplicationState: {
                    if (model[selectedIndex] === "Starting") {
                        return ApplicationInfoInterface.Starting;
                    } else if (model[selectedIndex] === "Running") {
                        return ApplicationInfoInterface.Running;
                    } else if (model[selectedIndex] === "Suspended") {
                        return ApplicationInfoInterface.Suspended;
                    } else {
                        return ApplicationInfoInterface.Stopped;
                    }
                }
                onSelectedApplicationStateChanged: {
                    // state is a read-only property, thus we have to call the setter function
                    if (fakeApplication && fakeApplication.state != selectedApplicationState) {
                        fakeApplication.setState(selectedApplicationState);
                    }
                }
                Connections {
                    target: fakeApplication
                    onStateChanged: {
                        testCase.setApplicationState(state);
                    }
                }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "ApplicationWindow"
        when: windowShown

        // just to make them shorter
        property int appStarting: ApplicationInfoInterface.Starting
        property int appRunning: ApplicationInfoInterface.Running
        property int appSuspended: ApplicationInfoInterface.Suspended
        property int appStopped: ApplicationInfoInterface.Stopped

        function setApplicationState(appState) {
            switch (appState) {
            case appStarting:
                appStateSelector.selectedIndex = 0;
                break;
            case appRunning:
                appStateSelector.selectedIndex = 1;
                break;
            case appSuspended:
                appStateSelector.selectedIndex = 2;
                break;
            case appStopped:
                appStateSelector.selectedIndex = 3;
                break;
            }
        }

        property var applicationWindow: applicationWindowLoader.item

        // holds some of the internal ApplicationWindow objects we probe during the tests
        property var stateGroup: null

        function findInterestingApplicationWindowChildren() {
            stateGroup = findInvisibleChild(applicationWindowLoader.item, "applicationWindowStateGroup");
            verify(stateGroup);
        }

        function forgetApplicationWindowChildren() {
            stateGroup = null;
        }

        function init() {
            findInterestingApplicationWindowChildren();
        }

        function cleanup() {
            forgetApplicationWindowChildren();

            applicationWindowLoader.itemDestroyed = false;

            // reload our test subject to get it in a fresh state once again
            applicationWindowLoader.active = false;

            tryCompare(applicationWindowLoader, "status", Loader.Null);
            tryCompare(applicationWindowLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same ApplicationWindow instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // ApplicationWindow instance gets destroyed.
            // Another thing that happens is that we do get a new object but the old one doesn't get
            // deleted, so you end up with two instances in memory.
            tryCompare(applicationWindowLoader, "itemDestroyed", true);

            surfaceCheckbox.checked = false;

            killApps();

            root.fakeApplication = ApplicationManager.add("gallery-app");
            root.fakeApplication.manualSurfaceCreation = true;

            applicationWindowLoader.active = true;

            applicationWindowLoader.item.application = root.fakeApplication;
        }

        function waitUntilSurfaceContainerStopsAnimating(container) {
            var animationsLoader = findChild(container, "animationsLoader");
            verify(animationsLoader);
            tryCompare(animationsLoader, "status", Loader.Ready)

            var animation = animationsLoader.item;
            waitUntilTransitionsEnd(animation);
        }

        function test_showSplashUntilAppFullyInit_data() {
            return [
                {tag: "state=Running then create surface", swapInitOrder: false},
                {tag: "create surface then state=Running", swapInitOrder: true},
            ]
        }

        function test_showSplashUntilAppFullyInit() {
            verify(stateGroup.state === "splash");

            if (data.swapInitOrder) {
                surfaceCheckbox.checked = true;
            } else {
                setApplicationState(appRunning);
            }

            verify(stateGroup.state === "splash");

            if (data.swapInitOrder) {
                setApplicationState(appRunning);
            } else {
                surfaceCheckbox.checked = true;
            }

            tryCompare(stateGroup, "state", "surface");
        }

        function test_suspendedAppShowsSurface() {
            surfaceCheckbox.checked = true;
            setApplicationState(appRunning);

            tryCompare(stateGroup, "state", "surface");

            waitUntilTransitionsEnd(stateGroup);

            setApplicationState(appSuspended);

            verify(stateGroup.state === "surface");
            waitUntilTransitionsEnd(stateGroup);
        }

        function test_restartApp() {
            tryCompare(stateGroup, "state", "splash");
            surfaceCheckbox.checked = true;
            setApplicationState(appRunning);
            tryCompare(stateGroup, "state", "surface");
            waitUntilTransitionsEnd(stateGroup);

            setApplicationState(appSuspended);

            // kill it
            surfaceCheckbox.checked = false;
            setApplicationState(appStopped);

            waitUntilTransitionsEnd(stateGroup);
            tryCompare(stateGroup, "state", "surface");

            // and restart it
            setApplicationState(appStarting);

            waitUntilTransitionsEnd(stateGroup);
            verify(stateGroup.state === "surface");

            setApplicationState(appRunning);

            waitUntilTransitionsEnd(stateGroup);
            verify(stateGroup.state === "surface");

            surfaceCheckbox.checked = true;

            tryCompare(stateGroup, "state", "surface");
        }

        function test_appCrashed() {
            surfaceCheckbox.checked = true;
            setApplicationState(appRunning);
            tryCompare(stateGroup, "state", "surface");
            waitUntilTransitionsEnd(stateGroup);
            var surface = applicationWindow.surface;

            // oh, it crashed...
            surfaceCheckbox.checked = false;
            setApplicationState(appStopped);

            waitUntilTransitionsEnd(stateGroup);
            tryCompare(stateGroup, "state", "surface");
            tryCompare(applicationWindow, "surface", surface);
        }

        function test_keepSurfaceWhileInvisible() {
            surfaceCheckbox.checked = true;
            setApplicationState(appRunning);
            tryCompare(stateGroup, "state", "surface");
            waitUntilTransitionsEnd(stateGroup);
            verify(applicationWindow.surface !== null);

            applicationWindow.visible = false;

            waitUntilTransitionsEnd(stateGroup);
            verify(stateGroup.state === "surface");
            verify(applicationWindow.surface !== null);

            applicationWindow.visible = true;

            waitUntilTransitionsEnd(stateGroup);
            verify(stateGroup.state === "surface");
            verify(applicationWindow.surface !== null);
        }

        function test_touchesReachSurfaceWhenItsShown() {
            setApplicationState(appRunning);
            surfaceCheckbox.checked = true;

            tryCompare(stateGroup, "state", "surface");

            waitUntilTransitionsEnd(stateGroup);

            var surfaceItem = findChild(applicationWindow, "surfaceItem");
            verify(surfaceItem);
            verify(surfaceItem.surface === applicationWindow.surface);

            surfaceItem.touchPressCount = 0;
            surfaceItem.touchReleaseCount = 0;

            tap(applicationWindow);

            verify(surfaceItem.touchPressCount === 1);
            verify(surfaceItem.touchReleaseCount === 1);
        }

        function test_surfaceActiveFocusFollowsAppWindowInterative() {
            applicationWindow.interactive = false;
            applicationWindow.interactive = true;
            surfaceCheckbox.checked = true;

            compare(applicationWindow.surface.activeFocus, true);

            applicationWindow.interactive = false;
            compare(applicationWindow.surface.activeFocus, false);

            applicationWindow.interactive = true;
            compare(applicationWindow.surface.activeFocus, true);
        }

        function test_promptSurfaceDestructionReturnsFocusToPreviousSurface() {
            surfaceCheckbox.checked = true;
            var promptSurfaces = testCase.findChild(applicationWindow, "promptSurfacesRepeater");
            var promptSurfaceList = root.fakeApplication.promptSurfaceList;
            compare(promptSurfaces.count, 0);

            var i;
            // 3 surfaces should cover all edge cases
            for (i = 0; i < 3; i++) {
                root.fakeApplication.createPromptSurface();
                compare(promptSurfaces.count, i+1);
                waitUntilSurfaceContainerStopsAnimating(promptSurfaces.itemAt(0));
            }

            for (i = 3; i > 0; --i) {
                var promptSurface = promptSurfaceList.get(0);
                compare(promptSurface.activeFocus, true);

                promptSurface.close();
                promptSurface = null;
                tryCompareFunction(function() { return promptSurfaces.count; }, i-1);

                if (promptSurfaces.count > 0) {
                    // active focus should have gone to the new head of the list
                    promptSurface = promptSurfaceList.get(0);
                    tryCompare(promptSurface, "activeFocus", true);
                } else {
                    // active focus should have gone to the application surface
                    tryCompare(applicationWindow.surface, "activeFocus", true);
                }
            }
        }

        function test_promptSurfaceAdjustsForParentSize() {
            root.fakeApplication.createPromptSurface();

            var promptSurfaces = testCase.findChild(applicationWindow, "promptSurfacesRepeater");

            var delegate = promptSurfaces.itemAt(0);
            waitUntilSurfaceContainerStopsAnimating(delegate);

            var promptSurfaceContainer = findChild(delegate, "surfaceContainer");

            tryCompareFunction(function() { return promptSurfaceContainer.height === applicationWindow.height; }, true);
            tryCompareFunction(function() { return promptSurfaceContainer.width === applicationWindow.width; }, true);
            tryCompareFunction(function() { return promptSurfaceContainer.x === 0; }, true);
            tryCompareFunction(function() { return promptSurfaceContainer.y === 0; }, true);

            applicationWindow.anchors.margins = units.gu(2);

            tryCompareFunction(function() { return promptSurfaceContainer.height === applicationWindow.height; }, true);
            tryCompareFunction(function() { return promptSurfaceContainer.width === applicationWindow.width; }, true);
            tryCompareFunction(function() { return promptSurfaceContainer.x === 0; }, true);
            tryCompareFunction(function() { return promptSurfaceContainer.y === 0; }, true);

            // clean up
            delegate.surface.close();
            tryCompare(promptSurfaces, "count", 0);
        }

        // Check that the z value of SurfaceContainers for prompt surfaces go from highest
        // for index 0 to lowest for the last index in the prompt surface list.
        // Regression test for https://bugs.launchpad.net/bugs/1586219
        function test_promptSurfacesZOrdering() {
            var promptSurfaceList = root.fakeApplication.promptSurfaceList;
            var promptSurfaces = testCase.findChild(applicationWindow, "promptSurfacesRepeater");

            root.fakeApplication.createPromptSurface();

            for (var i = 2; i <= 3; i++) {
                root.fakeApplication.createPromptSurface();
                tryCompare(promptSurfaces, "count", i);
                waitUntilSurfaceContainerStopsAnimating(promptSurfaces.itemAt(0));

                for (var j = 1; j < promptSurfaces.count; j++) {
                    var delegate = promptSurfaces.itemAt(j);
                    var previousDelegate = promptSurfaces.itemAt(j-1);
                    verify(previousDelegate.z > delegate.z);
                }
            }

            // clean up
            while (promptSurfaceList.count > 0) {
                var currentCount = promptSurfaceList.count;
                promptSurfaceList.get(0).close();
                tryCompare(promptSurfaceList, "count", currentCount - 1);
            }
        }
    }
}
