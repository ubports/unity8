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
import QtQuick.Layouts 1.1
import QtTest 1.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Unity.Application 0.1
import Unity.Test 0.1
import IntegratedLightDM 0.1 as LightDM
import Powerd 0.1
import Unity.InputInfo 0.1

import "../../qml"
import "../../qml/Components/UnityInputInfo"

Rectangle {
    id: root
    color: "grey"
    width:  units.gu(160) + controls.width
    height: units.gu(100)

    QtObject {
        id: applicationArguments
        property string deviceName: "mako"
        property string mode: "full-greeter"
    }

    QtObject {
        id: mockOrientationLock
        property int savedOrientation
    }

    QtObject {
        id: mockUnity8Settings
        property string usageMode: usageModeSelector.model[usageModeSelector.selectedIndex]
    }

    QtObject{
        id: mockOskSettings
        property bool stayHidden: false;
    }

    property int physicalOrientation0
    property int physicalOrientation90
    property int physicalOrientation180
    property int physicalOrientation270
    property real primaryOrientationAngle

    state: applicationArguments.deviceName
    states: [
        State {
            name: "mako"
            PropertyChanges {
                target: orientedShellLoader
                width: units.gu(40)
                height: units.gu(71)
            }
            PropertyChanges {
                target: root
                physicalOrientation0: Qt.PortraitOrientation
                physicalOrientation90: Qt.InvertedLandscapeOrientation
                physicalOrientation180: Qt.InvertedPortraitOrientation
                physicalOrientation270: Qt.LandscapeOrientation
                primaryOrientationAngle: 0
            }
        },
        State {
            name: "manta"
            PropertyChanges {
                target: orientedShellLoader
                width: units.gu(160)
                height: units.gu(100)
            }
            PropertyChanges {
                target: root
                physicalOrientation90: Qt.PortraitOrientation
                physicalOrientation180: Qt.InvertedLandscapeOrientation
                physicalOrientation270: Qt.InvertedPortraitOrientation
                physicalOrientation0: Qt.LandscapeOrientation
                primaryOrientationAngle: 0
            }
        },
        State {
            name: "flo"
            PropertyChanges {
                target: orientedShellLoader
                width: units.gu(62)
                height: units.gu(100)
            }
            PropertyChanges {
                target: root
                physicalOrientation270: Qt.PortraitOrientation
                physicalOrientation0: Qt.InvertedLandscapeOrientation
                physicalOrientation90: Qt.InvertedPortraitOrientation
                physicalOrientation180: Qt.LandscapeOrientation
                primaryOrientationAngle: 90
            }
        },
        State {
            name: "desktop"
            PropertyChanges {
                target: orientedShellLoader
                width: units.gu(100)
                height: units.gu(56)
            }
            PropertyChanges {
                target: root
                physicalOrientation270: Qt.InvertedPortraitOrientation
                physicalOrientation0:  Qt.LandscapeOrientation
                physicalOrientation90: Qt.PortraitOrientation
                physicalOrientation180: Qt.InvertedLandscapeOrientation
                primaryOrientationAngle: 0
            }
        }
    ]

    Loader {
        id: orientedShellLoader

        x: ((root.width - controls.width) - width) / 2
        y: (root.height - height) / 2

        focus: true

        property bool itemDestroyed: false
        sourceComponent: Component {
            OrientedShell {
                anchors.fill: parent
                unity8Settings: mockUnity8Settings
                oskSettings: mockOskSettings
                physicalOrientation: root.physicalOrientation0
                orientationLocked: orientationLockedCheckBox.checked
                orientationLock: mockOrientationLock
                Component.onDestruction: {
                    orientedShellLoader.itemDestroyed = true;
                }
            }
        }
    }

    function orientationsToStr(orientations) {
        if (orientations === Qt.PrimaryOrientation) {
            return "Primary";
        } else {
            var str = "";
            if (orientations & Qt.PortraitOrientation) {
                str += " Portrait";
            }
            if (orientations & Qt.InvertedPortraitOrientation) {
                str += " InvertedPortrait";
            }
            if (orientations & Qt.LandscapeOrientation) {
                str += " Landscape";
            }
            if (orientations & Qt.InvertedLandscapeOrientation) {
                str += " InvertedLandscape";
            }
            return str;
        }
    }

    Rectangle {
        width: controls.width
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        color: "darkgrey"
    }
    Flickable {
        id: controls
        width: units.gu(30)
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        boundsBehavior: Flickable.StopAtBounds
        contentHeight: controlsColumn.height

        Column {
            id: controlsColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            Button {
                text: "Show Greeter"
                activeFocusOnPress: false
                onClicked: {
                    if (orientedShellLoader.status !== Loader.Ready)
                        return;

                    LightDM.Greeter.showGreeter();
                }
            }
            Label {
                text: "Physical Orientation:"
            }
            Button {
                id: rotate0Button
                text: root.orientationsToStr(root.physicalOrientation0) + " (0)"
                activeFocusOnPress: false
                onClicked: {
                    orientedShellLoader.item.physicalOrientation = root.physicalOrientation0;
                }
            }
            Button {
                id: rotate90Button
                text: root.orientationsToStr(root.physicalOrientation90) + " (90)"
                activeFocusOnPress: false
                onClicked: {
                    orientedShellLoader.item.physicalOrientation = root.physicalOrientation90;
                }
            }
            Button {
                id: rotate180Button
                text: root.orientationsToStr(root.physicalOrientation180) + " (180)"
                activeFocusOnPress: false
                onClicked: {
                    orientedShellLoader.item.physicalOrientation = root.physicalOrientation180;
                }
            }
            Button {
                id: rotate270Button
                text: root.orientationsToStr(root.physicalOrientation270) + " (270)"
                activeFocusOnPress: false
                onClicked: {
                    orientedShellLoader.item.physicalOrientation = root.physicalOrientation270;
                }
            }
            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: orientationLockedCheckBox
                    checked: false
                    activeFocusOnPress: false
                }
                Label {
                    text: "Orientation Locked"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Button {
                text: "Power dialog"
                activeFocusOnPress: false
                onClicked: { testCase.showPowerDialog(); }
            }
            ListItem.ItemSelector {
                id: deviceNameSelector
                anchors { left: parent.left; right: parent.right }
                activeFocusOnPress: false
                text: "Device Name"
                model: ["mako", "manta", "flo", "desktop"]
                onSelectedIndexChanged: {
                    testCase.tearDown();
                    applicationArguments.deviceName = model[selectedIndex];
                    orientedShellLoader.active = true;
                }
            }
            ListItem.ItemSelector {
                id: usageModeSelector
                anchors { left: parent.left; right: parent.right }
                activeFocusOnPress: false
                text: "Usage Mode"
                model: ["Staged", "Windowed", "Automatic"]
            }
            MouseTouchEmulationCheckbox {
                checked: true
                color: "white"
            }
            Button {
                text: "Switch fullscreen"
                activeFocusOnPress: false
                onClicked: {
                    var app = ApplicationManager.findApplication(ApplicationManager.focusedApplicationId);
                    app.fullscreen = !app.fullscreen;
                }
            }
            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    checked: false
                    activeFocusOnPress: false
                    onCheckedChanged: {
                        var surface = SurfaceManager.inputMethodSurface();
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
            Button {
                text: Powerd.status === Powerd.On ? "Display ON" : "Display OFF"
                activeFocusOnPress: false
                onClicked: {
                    if (Powerd.status === Powerd.On) {
                        Powerd.setStatus(Powerd.Off, Powerd.Unknown);
                    } else {
                        Powerd.setStatus(Powerd.On, Powerd.Unknown);
                    }
                }
            }

            Row {
                Button {
                    text: "Add mouse"
                    activeFocusOnPress: false
                    onClicked: {
                        UnityInputInfo.inputInfo.addMockMouse()
                    }
                }
                Button {
                    text: "Remove mouse"
                    activeFocusOnPress: false
                    onClicked: {
                        UnityInputInfo.inputInfo.removeMockMouse()
                    }
                }
            }
            Row {
                Button {
                    text: "Add kbd"
                    activeFocusOnPress: false
                    onClicked: {
                        UnityInputInfo.inputInfo.addMockKeyboard()
                    }
                }
                Button {
                    activeFocusOnPress: false
                    text: "Remove kbd"
                    onClicked: {
                        UnityInputInfo.inputInfo.removeMockKeyboard()
                    }
                }
            }

            // Simulates what happens when the shell is moved to an external monitor and back
            Button {
                id: moveToFromMonitorButton
                text: applicationArguments.deviceName === "desktop" ? "Move to " + prevDevName + " screen" : "Move to desktop screen"
                activeFocusOnPress: false
                property string prevDevName: "mako"
                onClicked: {
                    usageModeSelector.selectedIndex = 2; // "Automatic"

                    if (applicationArguments.deviceName === "desktop") {
                        applicationArguments.deviceName = prevDevName;
                    } else {
                        prevDevName = applicationArguments.deviceName;
                        applicationArguments.deviceName = "desktop"
                    }
                }
            }
        }
    }

    UnityTestCase {
        id: testCase
        name: "OrientedShell"
        when: windowShown

        property Item orientedShell: orientedShellLoader.status === Loader.Ready ? orientedShellLoader.item : null
        property Item shell

        SignalSpy { id: signalSpy }
        SignalSpy { id: signalSpy2 }

        Connections {
            id: spreadRepeaterConnections
            ignoreUnknownSignals : true
            property var itemAddedCallback: null
            onItemAdded: {
                if (itemAddedCallback) {
                    itemAddedCallback(item);
                }
            }
        }

        function init() {
            if (orientedShellLoader.active) {
                // happens for the very first test function as shell
                // is loaded by default
                tearDown();
            }
        }

        function tearDown() {
            orientedShellLoader.itemDestroyed = false;
            orientedShellLoader.active = false;

            tryCompare(orientedShellLoader, "status", Loader.Null);
            tryCompare(orientedShellLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(orientedShellLoader, "itemDestroyed", true);

            // kill all (fake) running apps
            killApps();

            spreadRepeaterConnections.target = null;
            spreadRepeaterConnections.itemAddedCallback = null;
            signalSpy.target = null;
            signalSpy.signalName = "";

            LightDM.Greeter.authenticate(""); // reset greeter
        }

        function cleanup() {
            tryCompare(shell, "enabled", true); // make sure greeter didn't leave us in disabled state
            shell = null;

            tearDown();
        }

        function test_appSupportingOnlyPrimaryOrientationMakesShellStayPut_data() {
            return [
                {tag: "mako", deviceName: "mako"},
                {tag: "manta", deviceName: "manta"},
                {tag: "flo", deviceName: "flo"}
            ];
        }
        function test_appSupportingOnlyPrimaryOrientationMakesShellStayPut(data) {
            loadShell(data.deviceName);

            // unity8-dash supports only primary orientation and should be already running
            var dashAppWindow = findChild(shell, "appWindow_unity8-dash");
            verify(dashAppWindow);
            compare(ApplicationManager.focusedApplicationId, "unity8-dash");
            var dashApp = dashAppWindow.application
            verify(dashApp);
            compare(dashApp.rotatesWindowContents, false);
            compare(dashApp.supportedOrientations, Qt.PrimaryOrientation);
            compare(dashApp.stage, ApplicationInfoInterface.MainStage);

            tryCompareFunction(function(){return dashApp.session.surface != null;}, true);
            verify(checkAppSurfaceOrientation(dashAppWindow, dashApp, root.primaryOrientationAngle));

            compare(shell.transformRotationAngle, root.primaryOrientationAngle);
            rotateTo(90);

            verify(checkAppSurfaceOrientation(dashAppWindow, dashApp, root.primaryOrientationAngle));
            compare(shell.transformRotationAngle, root.primaryOrientationAngle);

            rotateTo(180);

            verify(checkAppSurfaceOrientation(dashAppWindow, dashApp, root.primaryOrientationAngle));
            compare(shell.transformRotationAngle, root.primaryOrientationAngle);

            rotateTo(270);

            verify(checkAppSurfaceOrientation(dashAppWindow, dashApp, root.primaryOrientationAngle));
            compare(shell.transformRotationAngle, root.primaryOrientationAngle);
        }

        function test_greeterRemainsInPrimaryOrientation_data() {
            return [
                {tag: "mako", deviceName: "mako"},
                {tag: "manta", deviceName: "manta"},
                {tag: "flo", deviceName: "flo"}
            ];
        }
        function test_greeterRemainsInPrimaryOrientation(data) {
            loadShell(data.deviceName);

            var gmailApp = ApplicationManager.startApplication("gmail-webapp");
            verify(gmailApp);

            // ensure the mock gmail-webapp is as we expect
            compare(gmailApp.rotatesWindowContents, false);
            compare(gmailApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);
            compare(gmailApp.stage, ApplicationInfoInterface.MainStage);

            // wait until it's able to rotate
            tryCompare(shell, "orientationChangesEnabled", true);

            compare(shell.transformRotationAngle, root.primaryOrientationAngle);
            rotateTo(90);
            tryCompare(shell, "transformRotationAngle", root.primaryOrientationAngle + 90);

            showGreeter();

            tryCompare(shell, "transformRotationAngle", root.primaryOrientationAngle);
            rotateTo(180);
            compare(shell.transformRotationAngle, root.primaryOrientationAngle);
            rotateTo(270);
            compare(shell.transformRotationAngle, root.primaryOrientationAngle);
            rotateTo(0);
            compare(shell.transformRotationAngle, root.primaryOrientationAngle);
        }

        function test_appRotatesWindowContents_data() {
            return [
                {tag: "mako", deviceName: "mako", orientationAngleAfterRotation: 90},
                {tag: "manta", deviceName: "manta", orientationAngleAfterRotation: 90},
                {tag: "flo", deviceName: "flo", orientationAngleAfterRotation: 180}
            ];
        }
        function test_appRotatesWindowContents(data) {
            loadShell(data.deviceName);
            var cameraApp = ApplicationManager.startApplication("camera-app");
            verify(cameraApp);

            // ensure the mock camera-app is as we expect
            compare(cameraApp.fullscreen, true);
            compare(cameraApp.rotatesWindowContents, true);
            compare(cameraApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);

            waitUntilAppSurfaceShowsUp("camera-app")

            var cameraSurface = cameraApp.session.surface;
            verify(cameraSurface);

            var focusChangedSpy = signalSpy;
            focusChangedSpy.clear();
            focusChangedSpy.target = cameraSurface;
            focusChangedSpy.signalName = "activeFocusChanged";
            verify(focusChangedSpy.valid);

            verify(cameraSurface.activeFocus);

            tryCompare(shell, "orientationChangesEnabled", true);

            var rotationStates = findInvisibleChild(orientedShell, "rotationStates");
            verify(rotationStates);
            var immediateTransition = null
            for (var i = 0; i < rotationStates.transitions.length && !immediateTransition; ++i) {
                var transition = rotationStates.transitions[i];
                if (transition.objectName == "immediateTransition") {
                    immediateTransition = transition;
                }
            }
            verify(immediateTransition);
            var transitionSpy = signalSpy2;
            transitionSpy.clear();
            transitionSpy.target = immediateTransition;
            transitionSpy.signalName = "runningChanged";
            verify(transitionSpy.valid);

            rotateTo(90);

            tryCompare(cameraSurface, "orientationAngle", data.orientationAngleAfterRotation);

            // the rotation should have been immediate
            // false -> true -> false
            compare(transitionSpy.count, 2);

            // It should retain native dimensions regardless of its rotation/orientation
            compare(cameraSurface.width, orientedShell.width);
            compare(cameraSurface.height, orientedShell.height);

            // Surface focus shouldn't have been touched because of the rotation
            compare(focusChangedSpy.count, 0);
        }

        /*
            Preconditions:
            Shell orientation angle matches the screen one.

            Use case:
            User switches to an app that has an orientation angle different from the
            shell one but that also happens to support the current shell orientation
            angle.

            Expected outcome:
            The app should get rotated to match shell's orientation angle
         */
        function test_switchingToAppWithDifferentRotation_data() {
            return [
                {tag: "mako", deviceName: "mako", shellAngleAfterRotation: 90},
                {tag: "manta", deviceName: "manta", shellAngleAfterRotation: 90},
                {tag: "flo", deviceName: "flo", shellAngleAfterRotation: 180}
            ];
        }
        function test_switchingToAppWithDifferentRotation(data) {
            loadShell(data.deviceName);
            var gmailApp = ApplicationManager.startApplication("gmail-webapp");
            verify(gmailApp);

            // ensure the mock gmail-webapp is as we expect
            compare(gmailApp.rotatesWindowContents, false);
            compare(gmailApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);
            compare(gmailApp.stage, ApplicationInfoInterface.MainStage);

            waitUntilAppSurfaceShowsUp("gmail-webapp")

            var musicApp = ApplicationManager.startApplication("music-app");
            verify(musicApp);

            // ensure the mock music-app is as we expect
            compare(musicApp.rotatesWindowContents, false);
            compare(musicApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);
            compare(musicApp.stage, ApplicationInfoInterface.MainStage);

            waitUntilAppSurfaceShowsUp("music-app")
            tryCompare(shell, "orientationChangesEnabled", true);

            rotateTo(90);
            tryCompare(shell, "transformRotationAngle", data.shellAngleAfterRotation);

            performEdgeSwipeToSwitchToPreviousApp();

            tryCompare(shell, "mainAppWindowOrientationAngle", data.shellAngleAfterRotation);
            compare(shell.transformRotationAngle, data.shellAngleAfterRotation);
        }

        /*
            Preconditions:
            - Device supports portrait, landscape and inverted-landscape

            Steps:
            1 - Launch app that supports all orientations
            2 - Rotate device to inverted-landscape
            3 - See that shell gets rotated to inverted-landscape accordingly
            4 - Rotate device to inverted-portrait

            Expected outcome:
            Shell stays at inverted-landscape

            Actual outcome:
            Shell rotates to landscape

            Comments:
            Rationale being that shell should be rotated to the closest supported orientation.
            In that case, landscape and inverted-landscape are both 90 degrees away from the physical
            orientation (Screen.orientation), so they are both equally good alternatives
         */
        function test_rotateToUnsupportedDeviceOrientation(data) {
            loadShell("mako");
            var twitterApp = ApplicationManager.startApplication("twitter-webapp");
            verify(twitterApp);

            // ensure the mock twitter-webapp is as we expect
            compare(twitterApp.rotatesWindowContents, false);
            compare(twitterApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);

            waitUntilAppSurfaceShowsUp("twitter-webapp")

            rotateTo(data.rotationAngle);
            tryCompare(shell, "transformRotationAngle", data.rotationAngle);

            rotateTo(180);
            tryCompare(shell, "transformRotationAngle", data.rotationAngle);
        }
        function test_rotateToUnsupportedDeviceOrientation_data() {
            return [
                {tag: "90", rotationAngle: 90},
                {tag: "270", rotationAngle: 270}
            ];
        }

        function test_launchLandscapeOnlyAppFromPortrait() {
            loadShell("mako");
            var weatherApp = ApplicationManager.startApplication("ubuntu-weather-app");
            verify(weatherApp);

            // ensure the mock app is as we expect
            compare(weatherApp.supportedOrientations, Qt.LandscapeOrientation | Qt.InvertedLandscapeOrientation);

            waitUntilAppSurfaceShowsUp("ubuntu-weather-app");

            var rotationStates = findInvisibleChild(orientedShell, "rotationStates");
            waitUntilTransitionsEnd(rotationStates);

            tryCompareFunction(function (){return shell.transformRotationAngle === 90
                                               || shell.transformRotationAngle === 270;}, true);
        }

        /*
            - launch an app that supports all orientations, such as twitter-webapp
            - wait a bit until that app is considered to have finished initializing and is thus
              ready to get resized/rotated
            - switch back to dash
            - rotate device to 90 degrees
            - Physical orientation is 90 but Shell orientation is kept at 0 because unity8-dash
              doesn't support such orientation
            - do a long right-edge drag to show the apps spread
            - tap on twitter-webapp

            Shell will rotate to match the physical orientation.

            This is a kind of tricky case as there are a few things happening at the same time:
              1 - Stage switching from apps spread (phase 2) to showing the focused app (phase 0)
              2 - orientation and aspect ratio (ie size) changes

            This may trigger some corner case bugs. such as one were
            the greeter is not kept completely outside the shell, causing the black rect in Shell.qml
            have an opacity > 0.
         */
        function test_greeterStaysAwayAfterRotation() {
            loadShell("mako");
            var twitterApp = ApplicationManager.startApplication("twitter-webapp");
            verify(twitterApp);

            // ensure the mock twitter-webapp is as we expect
            compare(twitterApp.rotatesWindowContents, false);
            compare(twitterApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);

            waitUntilAppSurfaceShowsUp("twitter-webapp");
            waitUntilAppWindowCanRotate("twitter-webapp");

            // go back to unity8-dash
            performEdgeSwipeToSwitchToPreviousApp();

            rotateTo(90);
            wait(1); // spin the event loop to let all bindings do their thing
            // should not rotat as unity8-dash doesn't support it
            tryCompare(shell, "transformRotationAngle", 0);

            performEdgeSwipeToShowAppSpread();

            // wait until things have settled
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "animating", false);

            var twitterDelegate = findChild(shell, "appDelegate1");
            compare(twitterDelegate.application.appId, "twitter-webapp");
            twitterDelegate.clicked();

            // now it should finally follow the physical orientation
            tryCompare(shell, "transformRotationAngle", 90);

            // greeter should remaing completely hidden
            tryCompare(greeter, "shown", false);
        }

        function test_appInSideStageDoesntRotateOnStartUp_data() {
            return [
                {tag: "manta", deviceName: "manta"},
                {tag: "flo", deviceName: "flo"}
            ];
        }
        function test_appInSideStageDoesntRotateOnStartUp(data) {
            loadShell(data.deviceName);

            var twitterDelegate = null;

            verify(spreadRepeaterConnections.target);
            spreadRepeaterConnections.itemAddedCallback = function(item) {
                verify(item.application.appId, "twitter-webapp");
                twitterDelegate = item;
                signalSpy.target = findInvisibleChild(item, "orientationChangeAnimation");
                verify(signalSpy.valid);
            }

            signalSpy.clear();
            signalSpy.target = null;
            signalSpy.signalName = "runningChanged";

            var twitterApp = ApplicationManager.startApplication("twitter-webapp");
            verify(twitterApp);

            // ensure the mock twitter-webapp is as we expect
            compare(twitterApp.rotatesWindowContents, false);
            compare(twitterApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);
            compare(twitterApp.stage, ApplicationInfoInterface.SideStage);

            // Wait until spreadRepeaterConnections hs caught the new SpreadDelegate and
            // set up the signalSpy target accordingly.
            tryCompareFunction(function(){ return signalSpy.target != null && signalSpy.valid; }, true);

            tryCompare(twitterDelegate, "orientationChangesEnabled", true);

            var appWindowWithShadow = findChild(twitterDelegate, "appWindowWithShadow");
            verify(appWindowWithShadow);
            tryCompare(appWindowWithShadow, "state", "keepSceneRotation");

            // no reason for any rotation animation to have taken place
            compare(signalSpy.count, 0);
        }

        function test_portraitOnlyAppInSideStage_data() {
            return [
                {tag: "manta", deviceName: "manta"},
                {tag: "flo", deviceName: "flo"}
            ];
        }
        function test_portraitOnlyAppInSideStage(data) {
            loadShell(data.deviceName);

            var dialerDelegate = null;
            verify(spreadRepeaterConnections.target);
            spreadRepeaterConnections.itemAddedCallback = function(item) {
                dialerDelegate = item;
                verify(item.application.appId, "dialer-app");
            }

            var dialerApp = ApplicationManager.startApplication("dialer-app");
            verify(dialerApp);

            // ensure the mock dialer-app is as we expect
            compare(dialerApp.rotatesWindowContents, false);
            compare(dialerApp.supportedOrientations, Qt.PortraitOrientation | Qt.InvertedPortraitOrientation);
            compare(dialerApp.stage, ApplicationInfoInterface.SideStage);

            tryCompareFunction(function(){ return dialerDelegate != null; }, true);
            tryCompare(dialerDelegate, "orientationChangesEnabled", true);

            var appWindowWithShadow = findChild(dialerDelegate, "appWindowWithShadow");
            verify(appWindowWithShadow);
            tryCompare(appWindowWithShadow, "state", "keepSceneRotation");

            // app must have portrait aspect ratio
            verify(appWindowWithShadow.width < appWindowWithShadow.height);

            compare(appWindowWithShadow.rotation, 0);

            verifyAppWindowWithinSpreadDelegateBoundaries(dialerDelegate);

            // shell should remain in its primery orientation as the app in the main stage
            // is the one that dictates its orientation. In this case it's unity8-dash
            // which supports only primary orientation
            compare(shell.orientation, orientedShell.primaryOrientation);
        }

        function test_sideStageAppsRemainPortraitInSpread_data() {
            return [
                {tag: "manta", deviceName: "manta"},
                {tag: "flo", deviceName: "flo"}
            ];
        }
        function test_sideStageAppsRemainPortraitInSpread(data) {
            loadShell(data.deviceName);


            ////
            // Launch dialer
            var dialerDelegate = null;
            verify(spreadRepeaterConnections.target);
            spreadRepeaterConnections.itemAddedCallback = function(item) {
                dialerDelegate = item;
                verify(item.application.appId, "dialer-app");
            }

            var dialerApp = ApplicationManager.startApplication("dialer-app");
            verify(dialerApp);

            // ensure the mock dialer-app is as we expect
            compare(dialerApp.rotatesWindowContents, false);
            compare(dialerApp.supportedOrientations, Qt.PortraitOrientation | Qt.InvertedPortraitOrientation);
            compare(dialerApp.stage, ApplicationInfoInterface.SideStage);

            tryCompareFunction(function(){ return dialerDelegate != null; }, true);
            waitUntilAppDelegateIsFullyInit(dialerDelegate);


            ////
            // Launch twitter
            var twitterDelegate = null;
            spreadRepeaterConnections.itemAddedCallback = function(item) {
                twitterDelegate = item;
                verify(item.application.appId, "twitter-webapp");
            }

            var twitterApp = ApplicationManager.startApplication("twitter-webapp");
            verify(twitterApp);

            // ensure the mock twitter-webapp is as we expect
            compare(twitterApp.rotatesWindowContents, false);
            compare(twitterApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);
            compare(twitterApp.stage, ApplicationInfoInterface.SideStage);

            tryCompareFunction(function(){ return twitterDelegate != null; }, true);
            waitUntilAppDelegateIsFullyInit(twitterDelegate);

            ////
            // Edge swipe to show spread and check orientations

            performEdgeSwipeToShowAppSpread();

            {
                var appWindowWithShadow = findChild(dialerDelegate, "appWindowWithShadow");
                verify(appWindowWithShadow);
                tryCompare(appWindowWithShadow, "state", "keepSceneRotation");
                compare(appWindowWithShadow.width, dialerDelegate.width);
                compare(appWindowWithShadow.height, dialerDelegate.height);
                compare(appWindowWithShadow.rotation, 0);
            }
            {
                var appWindowWithShadow = findChild(twitterDelegate, "appWindowWithShadow");
                verify(appWindowWithShadow);
                tryCompare(appWindowWithShadow, "state", "keepSceneRotation");
                compare(appWindowWithShadow.width, twitterDelegate.width);
                compare(appWindowWithShadow.height, twitterDelegate.height);
                compare(appWindowWithShadow.rotation, 0);
            }

            verifyAppWindowWithinSpreadDelegateBoundaries(dialerDelegate);
            verifyAppWindowWithinSpreadDelegateBoundaries(twitterDelegate);
        }

        function test_launchedAppHasActiveFocus_data() {
            return [
                {tag: "mako", deviceName: "mako"},
                {tag: "manta", deviceName: "manta"},
                {tag: "flo", deviceName: "flo"}
            ];
        }
        function test_launchedAppHasActiveFocus(data) {
            loadShell(data.deviceName);

            var gmailApp = ApplicationManager.startApplication("gmail-webapp");
            verify(gmailApp);
            waitUntilAppSurfaceShowsUp("gmail-webapp")

            verify(gmailApp.session.surface);

            tryCompare(gmailApp.session.surface, "activeFocus", true);
        }

        function test_launchLandscapeOnlyAppOverPortraitOnlyDashThenSwitchToDash() {
            loadShell("mako");

            // starts as portrait, as unity8-dash is portrait only
            tryCompare(shell, "transformRotationAngle", 0);

            var weatherApp = ApplicationManager.startApplication("ubuntu-weather-app");
            verify(weatherApp);

            // ensure the mock app is as we expect
            compare(weatherApp.supportedOrientations, Qt.LandscapeOrientation | Qt.InvertedLandscapeOrientation);

            waitUntilAppSurfaceShowsUp("ubuntu-weather-app");

            // should have rotated to landscape
            tryCompareFunction(function () { return shell.transformRotationAngle == 270
                                                 || shell.transformRotationAngle == 90; }, true);

            var rotationStates = findInvisibleChild(orientedShell, "rotationStates");
            waitUntilTransitionsEnd(rotationStates);

            performLeftEdgeSwipeToSwitchToDash();

            // Should be back to portrait
            tryCompare(shell, "transformRotationAngle", 0);
        }

        function test_attachRemoveInputDevices() {
            usageModeSelector.selectedIndex = 2;
            tryCompare(mockUnity8Settings, "usageMode", "Automatic")

            loadShell("mako")
            var shell = findChild(orientedShell, "shell");

            tryCompare(shell, "usageScenario", "phone");
            tryCompare(mockOskSettings, "stayHidden", false);

            UnityInputInfo.inputInfo.addMockKeyboard();
            tryCompare(shell, "usageScenario", "phone");
            tryCompare(mockOskSettings, "stayHidden", true);

            UnityInputInfo.inputInfo.addMockMouse();
            tryCompare(shell, "usageScenario", "desktop");
            tryCompare(mockOskSettings, "stayHidden", true);

            UnityInputInfo.inputInfo.removeMockKeyboard();
            tryCompare(shell, "usageScenario", "desktop");
            tryCompare(mockOskSettings, "stayHidden", false);

            UnityInputInfo.inputInfo.removeMockMouse();
            tryCompare(shell, "usageScenario", "phone");
            tryCompare(mockOskSettings, "stayHidden", false);
        }

        /*
            Regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1471609

            Steps:
             - Open an app which can rotate
             - Rotate the phone to landscape
             - Open the app spread
             - Press the power button while the app spread is open
             - Wait a bit and press power button again

            Expected outcome:
             You see greeter in portrat (ie, primary orientation)

            Actual outcome:
             You see greeter in landscape

            Comments:
             Greeter supports only the primary orientation (portrait in phones) but
             the stage doesn't allow orientation changes while the apps spread is open,
             hence the bug.
         */
        function test_phoneWithSpreadInLandscapeWhenGreeterShowsUp() {
            loadShell("mako");

            var gmailApp = ApplicationManager.startApplication("gmail-webapp");
            verify(gmailApp);

            // ensure the mock gmail-webapp is as we expect
            compare(gmailApp.rotatesWindowContents, false);
            compare(gmailApp.supportedOrientations, Qt.PortraitOrientation | Qt.LandscapeOrientation
                    | Qt.InvertedPortraitOrientation | Qt.InvertedLandscapeOrientation);

            // wait until it's able to rotate
            tryCompare(shell, "orientationChangesEnabled", true);

            rotateTo(90);
            tryCompare(shell, "transformRotationAngle", root.primaryOrientationAngle + 90);

            performEdgeSwipeToShowAppSpread();

            showGreeter();

            tryCompare(shell, "transformRotationAngle", root.primaryOrientationAngle);
        }

        /*
           Regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1476757

           Steps:
           1- have a portrait-only app in foreground (eg unity8-dash)
           2- launch or switch to some other application
           3- right-edge swipe to show the apps spread
           4- swipe up to close the current app (the one from step 2)
           5- lock the phone (press the power button)
           6- unlock the phone (press power button again and swipe greeter away)
               * app from step 1 should be on foreground and focused
           7- rotate phone

           Expected outcome:
           - The portrait-only application stays put

           Actual outcome:
           - The portrait-only application rotates freely
         */
        function test_lockPhoneAfterClosingAppInSpreadThenUnlockAndRotate() {
            loadShell("mako");

            var gmailApp = ApplicationManager.startApplication("gmail-webapp");
            verify(gmailApp);

            waitUntilAppSurfaceShowsUp("gmail-webapp");

            performEdgeSwipeToShowAppSpread();

            swipeToCloseCurrentAppInSpread();

            // press the power key once
            Powerd.setStatus(Powerd.Off, Powerd.Unknown);
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "fullyShown", true);

            // and a second time to turn the display back on
            Powerd.setStatus(Powerd.On, Powerd.Unknown);

            swipeAwayGreeter();

            verify(isAppSurfaceFocused("unity8-dash"))

            signalSpy.clear();
            signalSpy.target = shell;
            signalSpy.signalName = "widthChanged";
            verify(signalSpy.valid);

            rotateTo(90);

            // shell shouldn't have change its orientation at any moment
            compare(signalSpy.count, 0);
        }

        function test_moveToExternalMonitor() {
            loadShell("flo");

            compare(orientedShell.orientation, Qt.InvertedLandscapeOrientation);
            compare(shell.transformRotationAngle, 90);

            moveToFromMonitorButton.clicked();

            tryCompare(orientedShell, "orientation", Qt.LandscapeOrientation);
            tryCompare(shell, "transformRotationAngle" , 0);
        }

        //  angle - rotation angle in degrees clockwise, relative to the primary orientation.
        function rotateTo(angle) {
            switch (angle) {
            case 0:
                rotate0Button.clicked();
                break;
            case 90:
                rotate90Button.clicked();
                break;
            case 180:
                rotate180Button.clicked();
                break;
            case 270:
                rotate270Button.clicked();
                break;
            default:
                verify(false);
            }

            var rotationStates = findInvisibleChild(orientedShell, "rotationStates");
            verify(rotationStates.d);
            verify(rotationStates.d.stateUpdateTimer);

            // wait for the delayed state update to take place, if any
            tryCompare(rotationStates.d.stateUpdateTimer, "running", false);

            waitUntilTransitionsEnd(rotationStates);
        }

        function waitUntilAppDelegateIsFullyInit(spreadDelegate) {
            tryCompare(spreadDelegate, "orientationChangesEnabled", true);

            var appWindowWithShadow = findChild(spreadDelegate, "appWindowWithShadow");
            verify(appWindowWithShadow);
            tryCompare(appWindowWithShadow, "state", "keepSceneRotation");

            var appWindowStates = findInvisibleChild(appWindowWithShadow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function waitUntilAppSurfaceShowsUp(appId) {
            var appWindow = findChild(shell, "appWindow_" + appId);
            verify(appWindow);
            var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
            verify(appWindowStates);
            tryCompare(appWindowStates, "state", "surface");
        }

        function waitUntilAppWindowCanRotate(appId) {
            var appWindow = findChild(shell, "appWindow_" + appId);
            verify(appWindow);
            tryCompare(appWindow, "orientationChangesEnabled", true);
        }

        function waitUntilShellIsInOrientation(orientation) {
            tryCompare(shell, "orientation", orientation);
            var rotationStates = findInvisibleChild(orientedShell, "rotationStates");
            waitUntilTransitionsEnd(rotationStates);
        }

        function performLeftEdgeSwipeToSwitchToDash() {
            var spreadView = findChild(shell, "spreadView");
            var swipeLength = spreadView.width * 0.7;

            var touchStartX = 1;
            var touchStartY = shell.height / 2;
            touchFlick(shell,
                       touchStartX, touchStartY,
                       touchStartX + swipeLength, touchStartY);

            tryCompare(ApplicationManager, "focusedApplicationId", "unity8-dash");
        }

        function performEdgeSwipeToSwitchToPreviousApp() {
            // swipe just enough to ensure an app switch action.
            // If we swipe too much we will trigger the spread mode
            // and we don't want that.
            var spreadView = findChild(shell, "spreadView");
            verify(spreadView);

            verify(ApplicationManager.count >= 2);
            var previousApp = ApplicationManager.get(1);

            var touchStartX = shell.width - 1;
            var touchStartY = shell.height / 2;

            var condition;
            if (applicationArguments.deviceName === "phone") {
                condition = function() {
                    return spreadView.shiftedContentX > units.gu(2) &&
                        spreadView.shiftedContentX < spreadView.positionMarker1 * spreadView.width;
                };
            } else {
                condition = function() {
                    return spreadView.shiftedContentX > spreadView.width * spreadView.positionMarker1
                        && spreadView.shiftedContentX < spreadView.width * spreadView.positionMarker2;
                };
            }

            touchDragUntil(shell,
                    touchStartX, touchStartY,
                    -units.gu(1), 0,
                    condition);

            // ensure the app switch animation has ended
            tryCompare(spreadView, "shiftedContentX", 0);

            compare(ApplicationManager.get(0).appId, previousApp.appId);
        }

        function performEdgeSwipeToShowAppSpread() {
            var touchStartY = shell.height / 2;
            touchFlick(shell,
                       shell.width - 1, touchStartY,
                       0, touchStartY);

            var spreadView = findChild(shell, "spreadView");
            verify(spreadView);
            tryCompare(spreadView, "phase", 2);
            tryCompare(spreadView, "flicking", false);
            tryCompare(spreadView, "moving", false);
        }

        function showPowerDialog() {
            var dialogs = findChild(orientedShell, "dialogs");
            var dialogsPrivate = findInvisibleChild(dialogs, "dialogsPrivate");
            dialogsPrivate.showPowerDialog();
        }

        function verifyAppWindowWithinSpreadDelegateBoundaries(spreadDelegate) {
            var appWindowWithShadow = findChild(spreadDelegate, "appWindowWithShadow");
            verify(appWindowWithShadow);

            var windowInDelegateCoords = appWindowWithShadow.mapToItem(spreadDelegate, 0, 0,
                    appWindowWithShadow.width, appWindowWithShadow.height);

            compare(windowInDelegateCoords.x, 0);
            compare(windowInDelegateCoords.y, 0);
            compare(windowInDelegateCoords.width, spreadDelegate.width);
            compare(windowInDelegateCoords.height, spreadDelegate.height);
        }

        function swipeAwayGreeter() {
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "fullyShown", true);

            var touchX = shell.width - (shell.edgeSize / 2);
            var touchY = shell.height / 2;
            touchFlick(shell, touchX, touchY, shell.width * 0.1, touchY);

            // wait until the animation has finished
            tryCompare(greeter, "shown", false);
            waitForRendering(greeter);
        }

        function showGreeter() {
            LightDM.Greeter.showGreeter();
            // wait until the animation has finished
            var greeter = findChild(shell, "greeter");
            tryCompare(greeter, "fullyShown", true);
        }

        function killApps() {
            while (ApplicationManager.count > 1) {
                var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
                ApplicationManager.stopApplication(ApplicationManager.get(appIndex).appId);
            }
            compare(ApplicationManager.count, 1)
        }

        function loadShell(deviceName) {
            applicationArguments.deviceName = deviceName;

            // reload our test subject to get it in a fresh state once again
            orientedShellLoader.active = true;

            tryCompare(orientedShellLoader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(orientedShellLoader.item);

            shell = findChild(orientedShell, "shell");

            tryCompare(shell, "enabled", true); // enabled by greeter when ready

            waitUntilShellIsInOrientation(root.physicalOrientation0);

            waitForGreeterToStabilize();

            swipeAwayGreeter();

            var spreadRepeater = findChild(shell, "spreadRepeater");
            if (spreadRepeater) {
                spreadRepeaterConnections.target = spreadRepeater;
            }
        }

        function waitForGreeterToStabilize() {
            var greeter = findChild(shell, "greeter");
            verify(greeter);

            var loginList = findChild(greeter, "loginList");
            // Only present in WideView
            if (loginList) {
                var userList = findChild(loginList, "userList");
                verify(userList);
                tryCompare(userList, "movingInternally", false);
            }
        }

        // expectedAngle is in orientedShell's coordinate system
        function checkAppSurfaceOrientation(item, app, expectedAngle) {
            var surface = app.session.surface;
            if (!surface) {
                console.warn("no surface");
                return false;
            }

            var topMargin = 0.;
            if (!app.fullscreen) {
                var appsDisplayLoader = findChild(shell, "applicationsDisplayLoader");
                verify(appsDisplayLoader);
                verify(appsDisplayLoader.item);
                verify(appsDisplayLoader.item.maximizedAppTopMargin !== undefined);
                topMargin = appsDisplayLoader.item.maximizedAppTopMargin;
            }

            var surfaceItem = findSurfaceItem(item, surface);
            if (!surfaceItem) {
                console.warn("no surfaceItem rendering app surface");
                return false;
            }
            var point = surfaceItem.mapToItem(orientedShell, 0, 0);

            switch (expectedAngle) {
            case 0:
                return point.x === 0. && point.y === topMargin;
            case 90:
                return point.x === orientedShell.width - topMargin && point.y === 0;
            case 180:
                return point.x === orientedShell.width && point.y === orientedShell.height - topMargin;
            default: // 270
                return point.x === topMargin && point.y === orientedShell.height;
            }
        }

        function findSurfaceItem(obj, surface) {
            var childs = new Array(0);
            childs.push(obj)
            while (childs.length > 0) {
                if (childs[0].objectName === "surfaceItem"
                        && childs[0].surface !== undefined
                        && childs[0].surface === surface) {
                    return childs[0];
                }
                for (var i in childs[0].children) {
                    childs.push(childs[0].children[i])
                }
                childs.splice(0, 1);
            }
            return null;
        }

        function swipeToCloseCurrentAppInSpread() {
            var spreadView = findChild(shell, "spreadView");
            verify(spreadView);

            var delegateToClose = findChild(spreadView, "appDelegate0");
            verify(delegateToClose);

            var appIdToClose = ApplicationManager.get(0).appId;;
            var appCountBefore = ApplicationManager.count;

            // ensure the current app is widely visible by swiping to the right,
            // which will move the app windows accordingly
            touchFlick(shell,
                shell.width * 0.25, shell.width / 2,
                shell.width, shell.width / 2);

            tryCompare(spreadView, "flicking", false);
            tryCompare(spreadView, "moving", false);

            // Swipe up close to its left edge, as it is the only area of it guaranteed to be exposed
            // in the spread. Eg: its center could be covered by some other delegate.
            touchFlick(delegateToClose,
                1, delegateToClose.height / 2,
                1, - delegateToClose.height / 4);

            // ensure it got closed
            tryCompare(ApplicationManager, "count", appCountBefore - 1);
            compare(ApplicationManager.findApplication(appIdToClose), null);
        }

        function isAppSurfaceFocused(appId) {
            var appWindow = findChild(shell, "appWindow_" + appId);
            verify(appWindow);

            var app = ApplicationManager.findApplication(appId);
            verify(app);

            var surface = app.session.surface;
            verify(surface);

            var surfaceItem = findSurfaceItem(appWindow, surface);
            verify(surfaceItem);

            return surfaceItem.activeFocus;
        }
    }
}
