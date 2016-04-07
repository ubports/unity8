/*
 * Copyright (C) 2013,2014,2015 Canonical, Ltd.
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
import IntegratedLightDM 0.1 as LightDM
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import Unity.Test 0.1 as UT
import Utils 0.1

import "../../../qml"
import "../../../qml/Components"

Rectangle {
    id: root
    color: UbuntuColors.lightGrey
    width: units.gu(100) + buttons.width
    height: units.gu(71)

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

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDM.Greeter.mockMode = "single-pin";
        LightDM.Users.mockMode = "single-pin";
        shellLoader.active = true;
    }

    Item {
        id: shellContainer
        anchors.left: root.left
        anchors.right: buttons.left
        anchors.top: root.top
        anchors.bottom: root.bottom

        Loader {
            id: shellLoader

            active: false
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
                        target: shellLoader
                        width: units.gu(40)
                    }
                },
                State {
                    name: "tablet"
                    PropertyChanges {
                        target: shellLoader
                        width: units.gu(100)
                        shellOrientation: Qt.LandscapeOrientation
                        nativeOrientation: Qt.LandscapeOrientation
                        primaryOrientation: Qt.LandscapeOrientation
                    }
                },
                State {
                    name: "desktop"
                    PropertyChanges {
                        target: shellLoader
                        width: units.gu(100)
                    }
                }
            ]

            property bool itemDestroyed: false
            sourceComponent: Component {
                Shell {
                    usageScenario: shellLoader.state
                    nativeWidth: width
                    nativeHeight: height
                    property string indicatorProfile: "phone"
                    orientation: shellLoader.shellOrientation
                    orientations: Orientations {
                        native_: shellLoader.nativeOrientation
                        primary: shellLoader.primaryOrientation
                    }

                    Component.onDestruction: {
                        shellLoader.itemDestroyed = true;
                    }
                }
            }
        }
    }

    Rectangle {
        id: buttons
        color: UbuntuColors.darkGrey
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
                    text: "Hide Greeter"
                    onClicked: {
                        if (shellLoader.status !== Loader.Ready)
                            return;

                        var greeter = testCase.findChild(shellLoader.item, "greeter");
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
                        if (shellLoader.status !== Loader.Ready)
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
                        var surface = SurfaceManager.inputMethodSurface;
                        if (checked) {
                            surface.setState(Mir.RestoredState);
                        } else {
                            surface.setState(Mir.MinimizedState);
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

    UT.UnityTestCase {
        id: testCase
        name: "Tutorial"
        when: windowShown

        property Item shell: shellLoader.status === Loader.Ready ? shellLoader.item : null
        property real halfWidth: shell ?  shell.width / 2 : 0
        property real halfHeight: shell ? shell.height / 2 : 0

        function init() {
            prepareShell();

            var tutorialLeft = findChild(shell, "tutorialLeft");
            tryCompare(tutorialLeft, "opacity", 1);
        }

        function cleanup() {
            resetLoader("phone");
        }

        function resetLoader(state) {
            shellLoader.itemDestroyed = false;

            shellLoader.active = false;
            shellLoader.state = state;

            tryCompare(shellLoader, "status", Loader.Null);
            tryCompare(shellLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(shellLoader, "itemDestroyed", true);

            // kill all (fake) running apps
            killApps();

            // reload our test subject to get it in a fresh state once again
            shellLoader.active = true;

            tryCompare(shellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(shellLoader.item);
        }

        function prepareShell() {
            tryCompare(shell, "enabled", true); // enabled by greeter when ready

            WindowStateStorage.clear();
            SurfaceManager.inputMethodSurface.setState(Mir.MinimizedState);
            callManager.foregroundCall = null;
            AccountsService.demoEdges = false;
            AccountsService.demoEdgesCompleted = [];
            AccountsService.demoEdges = true;

            LightDM.Greeter.hideGreeter();
        }

        function loadShell(state) {
            resetLoader(state);
            prepareShell();
        }

        function swipeAwayGreeter() {
            var coverPage = findChild(shell, "coverPage");
            tryCompare(coverPage, "showProgress", 1);

            touchFlick(shell, halfWidth, halfHeight, shell.width, halfHeight);

            // wait until the animation has finished
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "required", false);
            waitForRendering(greeter);
        }

        function openTutorialTop() {
            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialTop = findChild(shell, "tutorialTop");
            var tutorialTopTimer = findInvisibleChild(tutorialTop, "tutorialTopTimer");

            tutorialTopTimer.interval = 1;
            AccountsService.demoEdgesCompleted = ["left", "left-long"];

            tryCompare(tutorialLeftLoader, "active", false);
            tryCompare(tutorialTop, "shown", true);
            tryCompare(tutorialTop, "opacity", 1);
        }

        function openTutorialRight() {
            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialRight = findChild(shell, "tutorialRight");

            AccountsService.demoEdgesCompleted = ["left", "left-long", "top"];
            ApplicationManager.startApplication("gallery-app");
            ApplicationManager.startApplication("facebook-webapp");

            tryCompare(tutorialLeftLoader, "active", false);
            tryCompare(tutorialRight, "shown", true);
            tryCompare(tutorialRight, "opacity", 1);
        }

        function openTutorialBottom() {
            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialBottom = findChild(shell, "tutorialBottom");

            AccountsService.demoEdgesCompleted = ["left", "left-long", "top", "right"];
            tryCompare(tutorialLeftLoader, "active", false);

            ApplicationManager.startApplication("dialer-app");
            ApplicationManager.requestFocusApplication("dialer-app");

            tryCompare(tutorialBottom, "shown", true);
            tryCompare(tutorialBottom, "opacity", 1);
        }

        function test_tutorialLeftEdges() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialLeft = findChild(tutorial, "tutorialLeft");
            var launcher = findChild(shell, "launcher");
            var stage = findChild(shell, "stage");
            var panel = findChild(shell, "panel");

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
            var tutorialLeft = findChild(tutorial, "tutorialLeft");
            var launcher = findChild(shell, "launcher");

            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight);

            tryCompare(tutorialLeft, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left"]);
            tryCompare(launcher, "state", "visible");
        }

        function test_tutorialLeftShortDrag() {
            // Here we want to test just barely pulling the launcher out and
            // letting go (i.e. not triggering the "progress" property of
            // Launcher).
            var tutorialLeft = findChild(shell, "tutorialLeft");
            var launcher = findChild(shell, "launcher");

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
            tryCompare(tutorialLeft, "shown", true); // and we should still be on left


            // Now drag out but not past launcher itself
            touchFlick(shell, 0, halfHeight, launcher.panelWidth * 0.9, halfHeight);

            tryCompare(tutorialLeft, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left"]);
            tryCompare(launcher, "state", "visible");
        }

        function test_tutorialLeftLongDrag() {
            // Just confirm that a long drag ("dash" drag) doesn't confuse us

            // So that we actually switch to dash and launcher hides
            ApplicationManager.startApplication("gallery-app");

            var launcher = findChild(shell, "launcher");
            var tutorialLeft = findChild(shell, "tutorialLeftLoader");
            verify(tutorialLeft);

            touchFlick(shell, 0, halfHeight, shell.width, halfHeight);

            tryCompare(tutorialLeft, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left", "left-long"]);
        }

        function test_tutorialLeftAutoSkipped() {
            // Test that we skip the tutorial if user uses left edge themselves

            var tutorialLeft = findChild(shell, "tutorialLeft");
            LightDM.Greeter.showGreeter();
            tryCompare(tutorialLeft, "visible", false);
            compare(AccountsService.demoEdgesCompleted, []);

            touchFlick(shell, 0, halfHeight, halfWidth, halfHeight);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left"]);
        }

        function test_tutorialTopEdges() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialTop = findChild(tutorial, "tutorialTop");
            var launcher = findChild(shell, "launcher");
            var stage = findChild(shell, "stage");
            var panel = findChild(shell, "panel");

            openTutorialTop();

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
            var tutorialTop = findChild(tutorial, "tutorialTop");
            var panel = findChild(shell, "panel");

            openTutorialTop();
            touchFlick(shell, halfWidth, 0, halfWidth, shell.height);

            tryCompare(tutorialTop, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left", "left-long", "top"]);
            tryCompare(panel.indicators, "fullyOpened", true);
        }

        function test_tutorialTopShortDrag() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialTop = findChild(tutorial, "tutorialTop");
            var panel = findChild(shell, "panel");

            openTutorialTop();
            touchFlick(shell, halfWidth, 0, halfWidth, shell.height * 0.4, true, false);
            // compare opacity with a bound rather than hard 0.6 because progress doesn't
            // always match the drag perfectly (takes a moment for drag to kick in)
            tryCompareFunction(function() {
                return tutorialTop.opacity >= 0.6 && tutorialTop.opacity < 0.7;
            }, true);
            touchFlick(shell, halfWidth, 0, halfWidth, shell.height * 0.4, false, true);

            compare(tutorialTop.shown, true);
        }

        function test_tutorialTopAutoSkipped() {
            // Test that we skip the tutorial if user uses top edge themselves

            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialTop = findChild(shell, "tutorialTop");
            AccountsService.demoEdgesCompleted = ["left", "left-long"];
            tryCompare(tutorialLeftLoader, "active", false);
            verify(!tutorialTop.shown);

            touchFlick(shell, halfWidth, 0, halfWidth, shell.height);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left", "left-long", "top"]);
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
            var tutorial = findChild(shell, "tutorial");
            var tutorialRight = findChild(tutorial, "tutorialRight");
            var stage = findChild(shell, "stage");

            openTutorialRight();
            touchFlick(shell, shell.width, halfHeight, 0, halfHeight);

            tryCompare(tutorialRight, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left", "left-long", "top", "right"]);
        }

        function test_tutorialRightShortDrag() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialRight = findChild(tutorial, "tutorialRight");
            var stage = findChild(shell, "stage");

            openTutorialRight();
            touchFlick(shell, shell.width, halfHeight, shell.width * 0.8, halfHeight, true, false);
            // compare opacity with a bound rather than hard 0.6 because progress doesn't
            // always match the drag perfectly (takes a moment for drag to kick in)
            tryCompareFunction(function() {
                return tutorialRight.opacity >= 0.6 && tutorialRight.opacity < 0.8;
            }, true);
            touchFlick(shell, shell.width, halfHeight, shell.width * 0.8, halfHeight, false, true);

            compare(tutorialRight.shown, true);
        }

        function test_tutorialRightDelay() {
            // Test that if we exit the top tutorial, we don't immediately
            // jump into right tutorial.
            var tutorialRight = findChild(shell, "tutorialRight");
            var tutorialRightTimer = findInvisibleChild(tutorialRight, "tutorialRightInactivityTimer");

            tutorialRightTimer.interval = 1;
            openTutorialTop();
            ApplicationManager.startApplication("gallery-app");
            ApplicationManager.startApplication("facebook-webapp");
            tryCompare(ApplicationManager, "count", 3);

            AccountsService.demoEdgesCompleted = ["left", "left-long", "top"];
            verify(tutorialRightTimer.running, true);
            verify(!tutorialRight.shown);
            tryCompare(tutorialRight, "shown", true);
        }

        function test_tutorialRightAutoSkipped() {
            // Test that we skip the tutorial if user uses right edge themselves

            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            AccountsService.demoEdgesCompleted = ["left", "left-long"];
            tryCompare(tutorialLeftLoader, "active", false);

            touchFlick(shell, shell.width, halfHeight, 0, halfHeight);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left", "left-long", "right"]);
        }

        function test_tutorialBottomEdges() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialBottom = findChild(tutorial, "tutorialBottom");
            var tutorialLabel = findChild(tutorialBottom, "tutorialLabel");
            var launcher = findChild(shell, "launcher");
            var stage = findChild(shell, "stage");
            var panel = findChild(shell, "panel");

            openTutorialBottom();

            tryCompare(tutorial, "running", true);
            verify(!tutorial.launcherEnabled);
            verify(!tutorial.spreadEnabled);
            verify(!tutorial.panelEnabled);
            verify(tutorialBottom.shown);
            verify(!launcher.available);
            verify(!stage.spreadEnabled);
            verify(!panel.indicators.available);
            compare(tutorialLabel.text, "Swipe up for recent calls");
        }

        function test_tutorialBottomFinish() {
            var tutorial = findChild(shell, "tutorial");
            var tutorialBottom = findChild(tutorial, "tutorialBottom");

            openTutorialBottom();
            touchFlick(shell, halfWidth, shell.height, halfWidth, halfHeight);

            tryCompare(tutorialBottom, "shown", false);
            tryCompare(AccountsService, "demoEdgesCompleted", ["left", "left-long", "top", "right", "bottom-dialer-app"]);

            // OK, we did one, just confirm that when all are done, we mark whole tutorial as done.
            verify(AccountsService.demoEdges);
            AccountsService.demoEdgesCompleted = ["left", "left-long", "top", "right",
                                                  "bottom-address-book-app",
                                                  "bottom-com.ubuntu.calculator_calculator",
                                                  "bottom-dialer-app",
                                                  "bottom-messaging-app"];
            verify(!AccountsService.demoEdges);
        }

        function test_tutorialBottomAppearsBeforeRight() {
            // Confirm that if bottom edge and right edge would appear on the
            // the same app open, bottom edge appears first. (this is a lightly
            // edited version of openTutorialRight)
            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialRight = findChild(shell, "tutorialRight");
            var tutorialBottom = findChild(shell, "tutorialBottom");

            AccountsService.demoEdgesCompleted = ["left", "left-long", "top"];
            ApplicationManager.startApplication("gallery-app");
            ApplicationManager.startApplication("dialer-app");

            tryCompare(tutorialLeftLoader, "active", false);
            tryCompare(tutorialBottom, "shown", true);
            tryCompare(tutorialBottom, "opacity", 1);
            tryCompare(tutorialRight, "visible", false);
        }

        function test_tutorialBottomOnlyCoversSideStageOnTablet() {
            loadShell("tablet");

            var tutorialBottom = findChild(shell, "tutorialBottom");
            var targetHeight = shell.height - units.gu(4);
            var mainStageX = units.gu(20);
            var sideStageX = shell.width - units.gu(20);

            WindowStateStorage.saveStage("dialer-app", ApplicationInfoInterface.SideStage);
            openTutorialBottom();

            touchFlick(shell, mainStageX, shell.height, mainStageX, targetHeight, true, false);
            compare(tutorialBottom.opacity, 1);
            touchFlick(shell, mainStageX, shell.height, mainStageX, targetHeight, false, true);

            touchFlick(shell, sideStageX, shell.height, sideStageX, targetHeight, true, false);
            verify(tutorialBottom.opacity < 1);
            touchFlick(shell, sideStageX, shell.height, sideStageX, targetHeight, false, true);
        }

        function test_tutorialBottomOnlyCoversMainStageOnTablet() {
            loadShell("tablet");

            var tutorialBottom = findChild(shell, "tutorialBottom");
            var targetHeight = shell.height - units.gu(4);
            var mainStageX = units.gu(20);
            var sideStageX = shell.width - units.gu(20);

            WindowStateStorage.saveStage("notes-app", ApplicationInfoInterface.SideStage);
            ApplicationManager.startApplication("notes-app");

            openTutorialBottom();

            touchFlick(shell, sideStageX, shell.height, sideStageX, targetHeight, true, false);
            compare(tutorialBottom.opacity, 1);
            touchFlick(shell, sideStageX, shell.height, sideStageX, targetHeight, false, true);

            touchFlick(shell, mainStageX, shell.height, mainStageX, targetHeight, true, false);
            verify(tutorialBottom.opacity < 1);
            touchFlick(shell, mainStageX, shell.height, mainStageX, targetHeight, false, true);
        }

        function test_activeCallInterruptsTutorial() {
            var tutorialLeft = findChild(shell, "tutorialLeft");
            verify(tutorialLeft.shown);
            verify(!tutorialLeft.paused);

            callManager.foregroundCall = phoneCall;
            verify(!tutorialLeft.shown);
            verify(tutorialLeft.paused);
            tryCompare(tutorialLeft, "visible", false);

            callManager.foregroundCall = null;
            tryCompare(tutorialLeft, "shown", true);
            verify(!tutorialLeft.paused);
        }

        function test_dialerInterruptionWithNoOverlappingTutorials() {
            var tutorialLeft = findChild(shell, "tutorialLeft");
            var tutorialBottom = findChild(shell, "tutorialBottom");
            verify(tutorialLeft.shown);

            // Start call, hiding left tutorial
            callManager.foregroundCall = phoneCall;
            tryCompare(tutorialLeft, "shown", false);

            // Start dialer app
            ApplicationManager.startApplication("dialer-app");
            tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");
            verify(!tutorialBottom.shown);

            // Dismiss call, bottom tutorial should appear
            callManager.foregroundCall = null;
            tryCompare(tutorialBottom, "shown", true);
            verify(!tutorialLeft.shown);

            // Get rid of bottom tutorial, left should now be shown
            touchFlick(shell, halfWidth, shell.height, halfWidth, halfHeight);
            tryCompare(tutorialBottom, "shown", false);
            tryCompare(tutorialLeft, "shown", true);
        }

        function test_greeterInterruptsTutorial() {
            var tutorialLeft = findChild(shell, "tutorialLeft");
            verify(tutorialLeft.shown);
            verify(!tutorialLeft.paused);

            LightDM.Greeter.showGreeter();
            verify(!tutorialLeft.shown);
            verify(tutorialLeft.paused);
            tryCompare(tutorialLeft, "visible", false);

            LightDM.Greeter.hideGreeter();
            tryCompare(tutorialLeft, "shown", true);
            verify(!tutorialLeft.paused);
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
            compare(AccountsService.demoEdgesCompleted, ["left", "left-long", "top"]);
        }

        function test_desktopOnlyShowsTutorialRight() {
            loadShell("desktop");

            var tutorialLeftLoader = findChild(shell, "tutorialLeftLoader");
            var tutorialTopLoader = findChild(shell, "tutorialTopLoader");
            var tutorialRightLoader = findChild(shell, "tutorialRightLoader");
            var tutorialBottomLoader = findChild(shell, "tutorialBottomLoader");
            verify(!tutorialLeftLoader.active);
            verify(!tutorialTopLoader.active);
            verify(tutorialRightLoader.active);
            verify(!tutorialBottomLoader.active);
            compare(AccountsService.demoEdgesCompleted, []);

            ApplicationManager.startApplication("dialer-app");
            ApplicationManager.startApplication("camera-app");
            tryCompare(tutorialRightLoader.item, "isReady", true);
            tryCompare(tutorialRightLoader, "shown", true);
        }

        function test_desktopTutorialRightFinish() {
            loadShell("desktop");

            var tutorialRight = findChild(shell, "tutorialRight");
            ApplicationManager.startApplication("dialer-app");
            ApplicationManager.startApplication("camera-app");
            tryCompare(tutorialRight, "shown", true);

            var stage = findChild(shell, "stage");
            mouseMove(shell, shell.width, shell.height / 2);
            stage.pushRightEdge(units.gu(8));
            tryCompare(tutorialRight, "shown", false);

            tryCompare(AccountsService, "demoEdges", false);
        }

        function test_oskDoesNotHideTutorial() {
            var tutorialLeft = findChild(shell, "tutorialLeft");
            verify(tutorialLeft.shown);

            var surface = SurfaceManager.inputMethodSurface;
            surface.setState(Mir.RestoredState);

            var inputMethod = findInvisibleChild(shell, "inputMethod");
            tryCompare(inputMethod, "state", "shown");

            verify(tutorialLeft.shown);
        }

        function test_oskPreventsTutorial() {
            var surface = SurfaceManager.inputMethodSurface;
            var inputMethod = findInvisibleChild(shell, "inputMethod");

            AccountsService.demoEdges = false;
            surface.setState(Mir.RestoredState);
            tryCompare(inputMethod, "state", "shown");

            var tutorial = findChild(shell, "tutorial");
            tryCompare(tutorial, "keyboardVisible", true);

            AccountsService.demoEdges = true;
            var tutorialLeft = findChild(shell, "tutorialLeft");
            verify(!tutorialLeft.shown);

            surface.setState(Mir.MinimizedState);
            tryCompare(inputMethod, "state", "hidden");
            tryCompare(tutorialLeft, "shown", false);
        }

        function test_accountsServiceSettings() {
            var tutorialLeft = findChild(shell, "tutorialLeft");
            verify(tutorialLeft != null);
            verify(tutorialLeft.shown);

            AccountsService.demoEdges = false;
            verify(findChild(shell, "tutorialLeft") == null);

            AccountsService.demoEdges = true;
            tutorialLeft = findChild(shell, "tutorialLeft");
            verify(tutorialLeft != null);
            tryCompare(tutorialLeft, "shown", true);
        }
    }
}
