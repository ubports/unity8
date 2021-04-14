/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import AccountsService 0.1
import LightDMController 0.1
import LightDM.FullLightDM 0.1 as LightDM
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3
import Lomiri.Telephony 0.1 as Telephony
import Lomiri.Application 0.1
import Lomiri.Notifications 1.0
import Lomiri.SelfTest 0.1 as UT
import Utils 0.1

import "../../../qml"
import "../../../qml/Components"

Rectangle {
    id: root
    color: LomiriColors.lightGrey
    width: units.gu(100) + buttons.width
    height: units.gu(71)

    property var shell: null

    QtObject {
        id: _screenWindow
        property bool primary: true
    }
    property alias screenWindow: _screenWindow

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    Component {
        id: mockNotification
        QtObject {}
    }

    ListModel {
        id: mockNotificationsModel

        function getRaw(id) {
            return mockNotification.createObject(mockNotificationsModel)
        }
    }

    function addNotification() {
        var n = {
            type: Notification.Confirmation,
            hints: {},
            summary: "",
            body: "",
            icon: "",
            secondaryIcon: "",
            actions: []
        };

        mockNotificationsModel.append(n);
    }

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDMController.userMode = "single-pin";
    }

    Component {
        id: shellComponent
        Shell {
            anchors.fill: parent
            usageScenario: shellRect.state
            nativeWidth: width
            nativeHeight: height
            property string indicatorProfile: "phone"
            orientation: shellRect.shellOrientation
            orientations: Orientations {
                native_: shellRect.nativeOrientation
                primary: shellRect.primaryOrientation
            }
            hasTouchscreen: true
            lightIndicators: true
        }
    }

    Item {
        id: shellContainer
        anchors.left: root.left
        anchors.right: buttons.left
        anchors.top: root.top
        anchors.bottom: root.bottom

        Rectangle {
            id: shellRect

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            property int shellOrientation: Qt.PortraitOrientation
            property int nativeOrientation: Qt.PortraitOrientation
            property int primaryOrientation: Qt.PortraitOrientation

            state: modeSelector.model[modeSelector.selectedIndex]
            states: [
                State {
                    name: "phone"
                    PropertyChanges {
                        target: shellRect
                        width: units.gu(40)
                    }
                },
                State {
                    name: "tablet"
                    PropertyChanges {
                        target: shellRect
                        width: units.gu(100)
                        shellOrientation: Qt.LandscapeOrientation
                        nativeOrientation: Qt.LandscapeOrientation
                        primaryOrientation: Qt.LandscapeOrientation
                    }
                },
                State {
                    name: "desktop"
                    PropertyChanges {
                        target: shellRect
                        width: units.gu(100)
                    }
                }
            ]
        }
    }

    Rectangle {
        id: buttons
        color: LomiriColors.darkGrey
        width: units.gu(30)
        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.right: root.right

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            Row {
                anchors { left: parent.left; right: parent.right }
                Button {
                    text: "Load shell"
                    onClicked: {
                        if (shell === null) {
                            shell = shellComponent.createObject(shellRect);
                            shell.focus = true;
                        }
                    }
                }
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                Button {
                    text: "Hide Greeter"
                    onClicked: {
                        if (root.shell === null)
                            return;

                        var greeter = testCase.findChild(shell, "greeter");
                        if (greeter.shown) {
                            greeter.hide();
                        }
                    }
                }
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                Button {
                    text: "Restart Tutorial"
                    onClicked: {
                        if (root.shell === null)
                            return;

                        AccountsService.demoEdges = false;
                        AccountsService.demoEdgesCompleted = [];
                        AccountsService.demoEdges = true;
                    }
                }
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {
                    onCheckedChanged: {
                        if (checked) {
                            callManager.foregroundCall = phoneCall;
                        } else {
                            callManager.foregroundCall = null;
                        }
                    }
                }
                Label {
                    text: "Active Call"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {
                    activeFocusOnPress: false
                    onCheckedChanged: {
                        var topLevelSurfaceList = findInvisibleChild(shell, "topLevelSurfaceList");
                        var surface = topLevelSurfaceList.inputMethodSurface;
                        if (checked) {
                            surface.requestState(Mir.RestoredState);
                        } else {
                            surface.requestState(Mir.MinimizedState);
                        }
                    }
                }
                Label {
                    text: "Input Method"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ItemSelector {
                id: modeSelector
                anchors { left: parent.left; right: parent.right }
                activeFocusOnPress: false
                text: "Mode"
                model: ["phone", "tablet", "desktop"]
            }
        }
    }

    UT.StageTestCase {
        id: testCase
        name: "Tutorial"
        when: windowShown

        property real halfWidth: shell ?  shell.width / 2 : 0
        property real halfHeight: shell ? shell.height / 2 : 0

        function init() {
            shell = createTemporaryObject(shellComponent, shellRect);
            prepareShell();

            var tutorialTop = findChild(shell, "tutorialTop");
            var tutorialTopTimer = findInvisibleChild(tutorialTop, "tutorialTopTimer");
            tutorialTopTimer.interval = 0;
            tryCompare(tutorialTop, "opacity", 1);
        }

        function cleanup() {
            mockNotificationsModel.clear();
            killApps();
            shellRect.state = "phone";
        }

        function prepareShell() {
            tryCompare(shell, "waitingOnGreeter", false); // reset by greeter when ready
            removeTimeConstraintsFromSwipeAreas(shell);

            WindowStateStorage.clear();
            callManager.foregroundCall = null;
            AccountsService.demoEdges = false;
            AccountsService.demoEdgesCompleted = [];
            AccountsService.demoEdges = true;

            LightDM.Greeter.hideGreeter();

            stage = findChild(shell, "stage"); // from StageTestCase
        }

        function loadShell(state) {
            shellRect.state = state;
            prepareShell();
        }

        function ensureInputMethodSurface(topLevelSurfaceList) {
            SurfaceManager.createInputMethodSurface();

            tryCompareFunction(function() { return topLevelSurfaceList.inputMethodSurface !== null }, true);
        }

        function openTutorialLeft() {
            var tutorialTopLoader = findChild(shell, "tutorialTopLoader");
            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialLeft = findInvisibleChild(tutorialLeftLoader, "tutorialLeft");
            var tutorialLeftTimer = findInvisibleChild(tutorialLeft, "tutorialLeftTimer");

            tutorialLeftTimer.interval = 1;
            AccountsService.demoEdgesCompleted = ["top"];

            tryCompare(tutorialTopLoader, "active", false);
            tryCompare(tutorialLeft, "shown", true);
            tryCompare(tutorialLeft, "opacity", 1);
        }

        function openTutorialLeftLong() {
            var tutorialLeftLong = findChild(shell, "tutorialLeftLong");
            var tutorialLeftLongTimer = findChild(tutorialLeftLong, "tutorialLeftLongTimer");

            AccountsService.demoEdgesCompleted = ["top", "left"];

            tutorialLeftLongTimer.interval = 1;
            tryCompare(tutorialLeftLong, "shown", true);
            tryCompare(tutorialLeftLong, "opacity", 1);
        }

        function openTutorialRight() {
            var tutorialLeftLongLoader = findChild(shell, "tutorialLeftLongLoader");
            var tutorialRight = findChild(shell, "tutorialRight");
            var tutorialRightTimer = findChild(tutorialRight, "tutorialRightTimer");

            AccountsService.demoEdgesCompleted = ["top", "left", "left-drawer"];
            ApplicationManager.startApplication("facebook-webapp");

            tryCompare(tutorialLeftLongLoader, "active", false);
            tutorialRightTimer.interval = 1;
            tryCompare(tutorialRight, "shown", true);
            tryCompare(tutorialRight, "opacity", 1);
        }

        function longLeftSwipe() {
            // Perform a long enough swipe to cause the Drawer to appear
            var launcher = findChild(shell, "launcher");
            var startX = launcher.dragAreaWidth/2;
            var startY = launcher.height/2;
            touchFlick(launcher,
                       startX, startY,
                       startX+units.gu(35), startY);
        }

        function test_tutorialLeftEdges() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialLeft = findChild(tutorial, "tutorialLeft");
            var launcher = findChild(shell, "launcher");
            var stage = findChild(shell, "stage");
            var panel = findChild(shell, "panel");

            openTutorialLeft();

            verify(tutorial.running);
            verify(tutorial.launcherEnabled);
            verify(!tutorial.spreadEnabled);
            verify(!tutorial.panelEnabled);
            verify(tutorialLeft.shown);
            verify(launcher.available);
            verify(!stage.spreadEnabled);
            verify(!panel.indicators.available);
        }

        function test_tutorialLeftFinish() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialLeftLoader = findChild(tutorial, "tutorialLeftLoader");
            var launcher = findChild(shell, "launcher");

            openTutorialLeft();

            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight);

            tryCompare(tutorialLeftLoader, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["top", "left"]);
            tryCompare(launcher, "state", "visible");
        }

        function test_tutorialLeftShortDrag() {
            // Here we want to test just barely pulling the launcher out and
            // letting go (i.e. not triggering the "progress" property of
            // Launcher).
            var tutorialLeft = findChild(shell, "tutorialLeft");
            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var launcher = findChild(shell, "launcher");

            openTutorialLeft();

            // Confirm fade during drag
            touchFlick(shell, 0, halfHeight, launcher.panelWidth * 0.4, halfHeight, true, false);
            // compare opacity with a bound rather than hard 0.6 because progress doesn't
            // always match the drag perfectly (takes a moment for drag to kick in)
            tryCompareFunction(function() {
                return tutorialLeft.opacity >= 0.6 && tutorialLeft.opacity < 0.8;
            }, true);
            touchFlick(shell, 0, halfHeight, launcher.panelWidth * 0.4, halfHeight, false, true);


            // Make sure we don't do anything if we don't pull the launcher
            // out much.
            touchFlick(shell, 0, halfHeight, launcher.panelWidth * 0.4, halfHeight);
            tryCompare(launcher, "state", ""); // should remain hidden
            tryCompare(tutorialLeftLoader, "shown", true); // and we should still be on left


            // Now drag out but not past launcher itself
            touchFlick(shell, 0, halfHeight, launcher.panelWidth * 0.9, halfHeight);

            tryCompare(tutorialLeftLoader, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["top", "left"]);
            tryCompare(launcher, "state", "visible");
        }

        function test_tutorialLeftLongFinish() {
            var tutorialLeftLongLoader = findChild(shell, "tutorialLeftLongLoader");
            openTutorialLeftLong();

            tryCompare(tutorialLeftLongLoader, "shown", true);

            touchFlick(shell, 0, halfHeight, shell.width, halfHeight);

            tryCompare(tutorialLeftLongLoader, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["top", "left", "left-drawer"]);
        }

        function test_tutorialLeftAutoSkipped() {
            // Test that we skip the tutorial if user uses left edge themselves
            var launcher = findChild(shell, "launcher");

            AccountsService.demoEdgesCompleted = ["top"]
            var tutorialLeft = findChild(shell, "tutorialLeft");
            launcher.show();
            tryCompare(tutorialLeft, "visible", false);
            compare(AccountsService.demoEdgesCompleted, ["top"]);

            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight);
            tryCompare(AccountsService, "demoEdgesCompleted", ["top", "left"]);
        }

        function test_tutorialLongLeftSwipeDisabled() {
            // Test that a long left swipe is disabled until we get to or pass
            // the long left tutorial.
            var tutorial = findChild(shell, "tutorial");
            var launcher = findChild(shell, "launcher");
            var drawer = findChild(launcher, "drawer");

            // Waiting for top tutorial, the Launcher should be unavailable
            longLeftSwipe();
            tryCompare(launcher, "state", "");

            // Swipe the left edge far enough to open the Drawer. Only the
            // Launcher should appear.
            openTutorialLeft();
            longLeftSwipe();
            tryCompare(launcher, "state", "visible");

            // Once the Drawer tutorial is open, the Drawer should appear on
            // a long swipe.
            openTutorialLeftLong();
            longLeftSwipe();
            tryCompare(launcher, "state", "drawer");
            launcher.hide();

            // That should continue after the Tutorial is no more
            AccountsService.demoEdges = false;
            tryCompare(tutorial, "running", false);
            longLeftSwipe();
            tryCompare(launcher, "state", "drawer");
        }

        function test_tutorialTopEdges() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialTop = findChild(tutorial, "tutorialTop");
            var launcher = findChild(shell, "launcher");
            var stage = findChild(shell, "stage");
            var panel = findChild(shell, "panel");

            tryCompare(tutorial, "running", true);
            verify(!tutorial.launcherEnabled);
            verify(!tutorial.spreadEnabled);
            verify(tutorial.panelEnabled);
            verify(tutorialTop.shown);
            verify(!launcher.available);
            verify(!stage.spreadEnabled);
            verify(panel.indicators.available);
        }

        function test_tutorialTopFinish() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialTopLoader = findChild(tutorial, "tutorialTopLoader");
            var panel = findChild(shell, "panel");

            touchFlick(shell, halfWidth, 0, halfWidth, shell.height);

            tryCompare(tutorialTopLoader, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["top"]);
            tryCompare(panel.indicators, "fullyOpened", true);
        }

        function test_tutorialTopShortDrag() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialTop = findChild(tutorial, "tutorialTop");
            var panel = findChild(shell, "panel");

            touchFlick(shell, halfWidth, 0, halfWidth, shell.height * 0.4, true, false);
            // compare opacity with a bound rather than hard 0.6 because progress doesn't
            // always match the drag perfectly (takes a moment for drag to kick in)
            tryCompareFunction(function() {
                return tutorialTop.opacity >= 0.5 && tutorialTop.opacity < 0.7;
            }, true);
            touchFlick(shell, halfWidth, 0, halfWidth, shell.height * 0.4, false, true);

            compare(tutorialTop.shown, true);
        }

        function test_tutorialRightEdges() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialRight = findChild(tutorial, "tutorialRight");
            var launcher = findChild(shell, "launcher");
            var stage = findChild(shell, "stage");
            var panel = findChild(shell, "panel");

            openTutorialRight();

            tryCompare(tutorial, "running", true);
            verify(!tutorial.launcherEnabled);
            verify(tutorial.spreadEnabled);
            verify(!tutorial.panelEnabled);
            verify(tutorialRight.shown);
            verify(!launcher.available);
            verify(stage.spreadEnabled);
            verify(!panel.indicators.available);
        }

        function test_tutorialRightFinish() {
            openTutorialRight();
            touchFlick(shell, shell.width, halfHeight, 0, halfHeight);

            tryCompare(AccountsService, "demoEdgesCompleted", ["top", "left", "left-drawer", "right"]);
            tryCompare(AccountsService, "demoEdges", false);
        }

        function test_tutorialRightShortDrag() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialRight = findChild(tutorial, "tutorialRight");
            var stage = findChild(shell, "stage");

            openTutorialRight();
            touchFlick(shell, shell.width, halfHeight, shell.width * 0.8, halfHeight, true, false);
            // compare opacity with a bound rather than hard 0.6 because progress doesn't
            // always match the drag perfectly (takes a moment for drag to kick in)
            verify(function() {
                return tutorialRight.opacity >= 0.6 && tutorialRight.opacity < 0.8;
            });
            touchFlick(shell, shell.width, halfHeight, shell.width * 0.8, halfHeight, false, true);

            compare(tutorialRight.shown, true);
        }

        function test_tutorialRightDelay() {
            // Test that if we exit the top tutorial, we don't immediately
            // jump into right tutorial.
            var tutorialRightLoader = findChild(shell, "tutorialRightLoader");
            var tutorialRightTimer = findInvisibleChild(tutorialRightLoader, "tutorialRightTimer");

            ApplicationManager.startApplication("gallery-app");
            tryCompare(ApplicationManager, "count", 1);

            AccountsService.demoEdgesCompleted = ["top", "left", "left-drawer"];
            verify(tutorialRightTimer.running);
            verify(!tutorialRightLoader.shown);
            tutorialRightTimer.interval = 1;
            tryCompare(tutorialRightLoader, "shown", true);
        }

        function test_tutorialRightAutoSkipped() {
            // Test that we skip the tutorial if user uses right edge themselves

            var tutorialLeftLongLoader = findChild(shell, "tutorialLeftLongLoader");
            var tutorialRight = findChild(shell, "tutorialRight");
            var tutorialRightTimer = findChild(tutorialRight, "tutorialRightTimer");

            tutorialRightTimer.interval = 9999999;

            ApplicationManager.startApplication("facebook-webapp");
            tryCompare(ApplicationManager, "count", 1);

            AccountsService.demoEdgesCompleted = ["top", "left", "left-drawer"];
            tryCompare(tutorialLeftLongLoader, "skipped", true);
            verify(tutorialRightTimer.running);
            tryCompare(tutorialRight, "isReady", true);

            // If the app isn't fully started, it may interrupt our attempt to swipe
            wait(1000);

            touchFlick(shell, shell.width, halfHeight, 0, halfHeight);
            tryCompare(AccountsService, "demoEdgesCompleted", ["top", "left", "left-drawer", "right"]);
        }

        function test_activeCallInterruptsTutorial() {
            var tutorialLeft = findChild(shell, "tutorialLeft");
            openTutorialLeft();

            callManager.foregroundCall = phoneCall;
            verify(!tutorialLeft.shown);
            verify(tutorialLeft.paused);
            tryCompare(tutorialLeft, "visible", false);

            callManager.foregroundCall = null;
            tryCompare(tutorialLeft, "shown", true);
            verify(!tutorialLeft.paused);
        }

        function test_greeterInterruptsTutorial() {
            var tutorialTop = findChild(shell, "tutorialTop");
            verify(tutorialTop.shown);
            verify(!tutorialTop.paused);

            LightDM.Greeter.showGreeter();
            verify(!tutorialTop.shown);
            verify(tutorialTop.paused);
            tryCompare(tutorialTop, "visible", false);

            LightDM.Greeter.hideGreeter();
            tryCompare(tutorialTop, "shown", true);
            verify(!tutorialTop.paused);
        }

        function test_interruptionChecksReadyStateWhenDone() {
            // If we're done with an interruption (like active call), make sure
            // that we don't blindly resume the tutorial -- our trigger
            // conditions still need to be met.  For example, there need to be
            // enough apps open for the right edge tutorial.

            openTutorialRight();

            var tutorialRight = findChild(shell, "tutorialRight");
            verify(tutorialRight.isReady);
            verify(tutorialRight.shown);
            verify(!tutorialRight.paused);

            callManager.foregroundCall = phoneCall;
            killApps();
            callManager.foregroundCall = null;

            verify(!tutorialRight.isReady);
            verify(!tutorialRight.shown);
            verify(!tutorialRight.paused);
            compare(AccountsService.demoEdgesCompleted, ["top", "left", "left-drawer"]);
        }

        function test_desktopOnlyShowsTutorialRight() {
            loadShell("desktop");

            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialTopLoader = findChild(shell, "tutorialTopLoader");
            var tutorialLeftLongLoader = findChild(shell, "tutorialLeftLongLoader");
            var tutorialRightLoader = findChild(shell, "tutorialRightLoader");
            verify(!tutorialLeftLoader.active);
            verify(!tutorialTopLoader.active);
            verify(!tutorialLeftLongLoader.active);
            verify(tutorialRightLoader.active);
            compare(AccountsService.demoEdgesCompleted, []);

            var tutorialRightTimer = findInvisibleChild(tutorialRightLoader, "tutorialRightTimer");
            tutorialRightTimer.interval = 1;

            ApplicationManager.startApplication("facebook-webapp");
            tryCompare(tutorialRightLoader.item, "isReady", true);

            tryCompare(tutorialRightLoader, "shown", true);
        }

        function test_desktopTutorialRightFinish() {
            loadShell("desktop");

            var tutorialRightLoader = findChild(shell, "tutorialRightLoader");
            var tutorialRightTimer = findInvisibleChild(tutorialRightLoader, "tutorialRightTimer");
            tutorialRightTimer.interval = 1;
            ApplicationManager.startApplication("facebook-webapp");
            tryCompare(tutorialRightLoader, "shown", true);

            var cursor = findChild(shell, "cursor");
            mouseMove(shell, shell.width, shell.height / 2);
            cursor.pushedRightBoundary(units.gu(8), 0);
            tryCompare(tutorialRightLoader, "shown", false);

            tryCompare(AccountsService, "demoEdges", false);
        }

        function test_oskDoesNotHideTutorial() {
            var topLevelSurfaceList = shell.topLevelSurfaceList;
            verify(topLevelSurfaceList);
            var tutorialTopLoader = findChild(shell, "tutorialTopLoader");
            verify(tutorialTopLoader.shown);

            ensureInputMethodSurface(topLevelSurfaceList);
            var surface = topLevelSurfaceList.inputMethodSurface;
            surface.requestState(Mir.RestoredState);

            var inputMethod = findInvisibleChild(shell, "inputMethod");
            tryCompare(inputMethod, "visible", true);

            verify(tutorialTopLoader.shown);
        }

        function test_oskDelaysTutorial() {
            var topLevelSurfaceList = shell.topLevelSurfaceList;
            verify(topLevelSurfaceList);
            var tutorial = findChild(shell, "tutorial");
            verify(!tutorial.delayed);

            ensureInputMethodSurface(topLevelSurfaceList);
            topLevelSurfaceList.inputMethodSurface.requestState(Mir.RestoredState);

            tryCompare(tutorial, "delayed", true);
        }

        function test_notificationDelaysTutorial() {
            var tutorial = findChild(shell, "tutorial");
            verify(!tutorial.delayed);

            var notifications = findChild(shell, "notificationList");
            notifications.model = mockNotificationsModel;
            addNotification(); // placeholder
            addNotification();

            tryCompare(tutorial, "delayed", true);
        }

        function test_dialogDelaysTutorial() {
            var tutorial = findChild(shell, "tutorial");
            verify(!tutorial.delayed);

            var dialogs = findChild(shell, "dialogs");
            dialogs.showPowerDialog();

            verify(tutorial.delayed);
        }

        function test_delayedTutorial() {
            var launcher = findChild(shell, "launcher");
            var tutorial = findChild(shell, "tutorial");
            var tutorialLeft = findChild(tutorial, "tutorialLeft");
            var tutorialLeftTimer = findChild(tutorial, "tutorialLeftTimer");
            // Since we'll be using the Launcher and Drawer, the left tutorial
            // will be skipped entirely and we'll show the left long one.
            var tutorialLeftLong = findChild(tutorial, "tutorialLeftLong");
            var tutorialLeftLongTimer = findChild(tutorialLeftLong, "tutorialLeftLongTimer");

            // Don't need these to start before we're ready
            tutorialLeftTimer.interval = 999999;
            tutorialLeftLongTimer.interval = 1;

            // Get left tutorial ready to be skipped
            AccountsService.demoEdgesCompleted = ["top"];
            tryCompare(tutorialLeft, "isReady", true);
            tryCompare(tutorialLeftTimer, "running", true);

            // Confirm that we become unready when delayed, but timer still goes
            tutorial.delayed = true;
            tryCompare(tutorialLeft, "isReady", false);
            tryCompare(tutorialLeftTimer, "running", true);

            // Confirm that we don't open the tutorial when delayed
            tutorialLeftTimer.interval = 1;
            wait(500);
            verify(!tutorialLeft.shown);

            // Confirm the Launcher and Drawer can be opened when delayed
            tryCompare(tutorial, "launcherEnabled", true);
            tryCompare(tutorial, "launcherLongSwipeEnabled", true);
            longLeftSwipe();
            tryCompare(launcher, "state", "drawer");
            launcher.hide();

            // Confirm we go back to normal when undelayed
            tutorial.delayed = false;
            tryCompare(tutorialLeftLong, "shown", true);
        }

        function test_accountsServiceSettings() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialTopLoader = findChild(tutorial, "tutorialTopLoader");
            verify(tutorialTopLoader.shown);

            AccountsService.demoEdges = false;
            verify(findChild(tutorial, "tutorialTopLoader", 1) == null);

            AccountsService.demoEdges = true;
            tutorialTopLoader = findChild(shell, "tutorialTopLoader");
            var tutorialTopTimer = findChild(tutorialTopLoader, "tutorialTopTimer");
            verify(tutorialTopTimer.running);
        }
    }
}
