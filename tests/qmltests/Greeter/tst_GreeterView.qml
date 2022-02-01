/*
 * Copyright 2014-2016 Canonical Ltd.
 * Copyright 2021 UBports Foundation
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
import QtQuick.Window 2.2
import QtTest 1.0
import ".."
import "../../../qml/Greeter"
import LightDMController 0.1
import LightDM.FullLightDM 0.1 as LightDM
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Test 0.1 as UT

StyledItem {
    id: root

    width: units.gu(160)
    height: units.gu(80)
    focus: true

    theme.name: "Ubuntu.Components.Themes.Ambiance"

    Component.onCompleted: {
        // must set the mock mode before loading the Shell
        LightDMController.userMode = "single";
    }

    Row {
        anchors.fill: parent
        Rectangle {
            width: root.width - controls.width
            height: parent.height
            color: "grey"

            Rectangle {
                id: viewContainer
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                focus: true

                Loader {
                    id: loader
                    width: parent.width
                    height: parent.height
                    focus: true

                    property bool itemDestroyed: false
                    sourceComponent: Component {
                        GreeterView {
                            id: view

                            background: "/usr/share/backgrounds/warty-final-ubuntu.png"
                            backgroundSourceSize: width
                            userModel: LightDM.Users
                            infographicModel: LightDM.Infographic

                            launcherOffset: parseFloat(launcherOffsetField.text)
                            currentIndex: parseInt(currentIndexField.text, 10)
                            delayMinutes: parseInt(delayMinutesField.text, 10)
                            panelHeight: parseFloat(panelHeightField.text)
                            locked: lockedCheckBox.checked
                            inputMethodRect: fakeKeyboard.childrenRect
                            property var testKeyboard: fakeKeyboard

                            usageMode: usageScenarioSelector.model[usageScenarioSelector.selectedIndex]
                            multiUser: multiUserCheckBox.checked
                            orientation: orientationSelector.model[orientationSelector.selectedIndex] == "landscape" ? Qt.LandscapeOrientation : Qt.PortraitOrientation

                            Component.onDestruction: {
                                loader.itemDestroyed = true
                            }

                            onSelected: {
                                if (index >= 0)
                                    currentIndexField.text = index;
                            }

                            Rectangle {
                                id: fakeKeyboard
                                color: "green"
                                opacity: 0.7
                                anchors.bottom: view.bottom
                                width: view.width
                                height: visible ? view.height * 0.6 : 0
                                visible: keyboardVisibleCheckBox.checked
                                Text {
                                    text: "Keyboard Rectangle"
                                    color: "yellow"
                                    font.bold: true
                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 10; font.pixelSize: 200
                                    verticalAlignment: Text.AlignVCenter
                                    x: (parent.width - width) / 2
                                    y: (parent.height - height) / 2
                                    width: parent.width
                                    height: parent.height
                                }
                            }
                        }
                    }
                }

                state: loader.item ? loader.item.usageMode + "-" + (loader.item.isLandscape ? "landscape" : "portrait") : "phone-portrait"

                states: [
                    State {
                        name: "phone-portrait"
                        PropertyChanges {
                            target: viewContainer
                            width: units.gu(40)
                            height: units.gu(71)
                        }
                    },
                    State {
                        name: "phone-landscape"
                        PropertyChanges {
                            target: viewContainer
                            width: units.gu(71)
                            height: units.gu(40)
                        }
                    },
                    State {
                        name: "tablet-landscape"
                        PropertyChanges {
                            target: viewContainer
                            width: units.gu(100)
                            height: units.gu(71)
                        }
                    },
                    State {
                        name: "tablet-portrait"
                        PropertyChanges {
                            target: viewContainer
                            width: units.gu(71)
                            height: units.gu(100)
                        }
                    },
                    State {
                        name: "desktop-portrait"
                        PropertyChanges {
                            target: viewContainer
                            width: parent.width
                            height: parent.height
                        }
                    },
                    State {
                        name: "desktop-landscape"
                        PropertyChanges {
                            target: viewContainer
                            width: parent.width
                            height: parent.height
                        }
                    }
                ]
            }
        }

        Rectangle {
            id: controls
            color: theme.palette.normal.background
            width: units.gu(40)
            height: parent.height
            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                spacing: units.gu(1)
                Row {
                    Button {
                        text: "Hide"
                        onClicked: loader.item.hide()
                    }
                }
                Row {
                    Button {
                        text: "Show Message"
                        onClicked: LightDMService.prompts.append(messageField.text, LightDMService.prompts.Message)
                    }
                    TextField {
                        id: messageField
                        width: units.gu(10)
                        text: ""
                    }
                }
                Row {
                    Button {
                        text: "Show Prompt"
                        onClicked: LightDMService.prompts.append(promptField.text, isSecretCheckBox.checked ? LightDMService.prompts.Secret : LightDMService.prompts.Question)
                    }
                    TextField {
                        id: promptField
                        width: units.gu(10)
                        text: ""
                    }
                    CheckBox {
                        id: isSecretCheckBox
                    }
                    Label {
                        text: "secret"
                    }
                }
                Row {
                    Button {
                        text: "Notify Auth Failure"
                        onClicked: {
                            loader.item.notifyAuthenticationFailed();
                        }
                    }
                }
                Row {
                    Button {
                        text: "Try To Unlock"
                        onClicked: loader.item.tryToUnlock(toTheRightCheckBox.checked)
                    }
                    CheckBox {
                        id: toTheRightCheckBox
                    }
                    Label {
                        text: "toTheRight"
                    }
                }
                Label {
                    text: "Usage scenario"
                }

                ListItem.ItemSelector {
                    id: usageScenarioSelector
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    model: ["phone", "tablet", "desktop"]
                }
                Label {
                    text: "Orientation"
                }

                ListItem.ItemSelector {
                    id: orientationSelector
                    anchors { left: parent.left; right: parent.right }
                    activeFocusOnPress: false
                    model: ["portrait", "landscape"]
                }
                Row {
                    TextField {
                        id: launcherOffsetField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "launcherOffset"
                    }
                }
                Row {
                    TextField {
                        id: currentIndexField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "currentIndex"
                    }
                }
                Row {
                    TextField {
                        id: delayMinutesField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "delayMinutes"
                    }
                }
                Row {
                    TextField {
                        id: panelHeightField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "panelHeight"
                    }
                }
                Row {
                    CheckBox {
                        id: lockedCheckBox
                    }
                    Label {
                        text: "locked"
                    }
                }
                Row {
                    CheckBox {
                        id: multiUserCheckBox
                        onClicked: {
                            if (checked) {
                                LightDMController.userMode = "full";
                            } else {
                                LightDMController.userMode = "single";
                            }
                        }
                        Connections {
                            target: LightDMController
                            onSessionModeChanged: {
                                if (LightDMController.userMode === "full") {
                                    multipleSessionsCheckbox.checked = true;
                                } else {
                                    multipleSessionsCheckbox.checked = false;
                                }
                            }
                        }
                    }
                    Label {
                        text: "multi user"
                    }
                }
                Row {
                    CheckBox {
                        id: alphanumericCheckBox
                        checked: true
                    }
                    Label {
                        text: "alphanumeric"
                    }
                }
                Row {
                    Label {
                        text: "selected: " + selectedSpy.count
                    }
                }
                Row {
                    Label {
                        text: "responded: " + respondedSpy.count
                    }
                }
                Row {
                    Label {
                        text: "teased: " + teaseSpy.count
                    }
                }
                Row {
                    Label {
                        text: "emergency: " + emergencySpy.count
                    }
                }
                Row {
                    Label {
                        text: "infographics: " + infographicDataChangedSpy.count
                    }
                }
                Row {
                    id: multipleSessions
                    CheckBox {
                        id: multipleSessionsCheckbox
                        onClicked: {
                            if (checked) {
                                LightDMController.sessionMode = "full";
                            } else {
                                LightDMController.sessionMode = "single";
                            }
                        }
                        Connections {
                            target: LightDMController
                            onSessionModeChanged: {
                                if (LightDMController.sessionMode === "full") {
                                    multipleSessionsCheckbox.checked = true;
                                } else {
                                    multipleSessionsCheckbox.checked = false;
                                }
                            }
                        }
                    }
                    Label {
                        text: "Multiple Sessions"
                    }
                }
                Row {
                    Slider {
                        id: numSessionsSlider

                        width: units.gu(10)
                        minimumValue: 0
                        maximumValue: LightDMController.numAvailableSessions
                        value: LightDMController.numSessions
                        visible: LightDMController.sessionMode === "full"
                        Binding {
                            target: LightDMController
                            property: "numSessions"
                            value: numSessionsSlider.value
                        }
                    }
                    Label {
                        text: "Available Sessions"
                    }
                }
                Row {
                    Button {
                        text: "Reload View"
                        onClicked: {
                            loader.active = false;
                            loader.active = true;
                        }
                    }
                }
                Row {
                    CheckBox {
                        id: keyboardVisibleCheckBox
                    }
                    Label {
                        text: "Keyboard Visible"
                    }
                }
            }
        }
    }

/* FIXME: infographic user is hardcoded to "has-password",
 * needs to be set to current user to test in multiUser mode
 */
    Binding {
        target: LightDM.Infographic
        property: "username"
        value: "has-password"
    }

    SignalSpy {
        id: selectedSpy
        target: loader.item
        signalName: "selected"
    }

    SignalSpy {
        id: respondedSpy
        target: loader.item
        signalName: "responded"
    }

    SignalSpy {
        id: teaseSpy
        target: loader.item
        signalName: "tease"
    }

    SignalSpy {
        id: emergencySpy
        target: loader.item
        signalName: "emergencyCall"
    }

    SignalSpy {
        id: infographicDataChangedSpy
        target: LightDM.Infographic
        signalName: "dataChanged"
    }

    UT.UnityTestCase {
        name: "GreeterView"
        when: windowShown

        property Item view: loader.status === Loader.Ready ? loader.item : null
        property url testIconDirectory: Qt.resolvedUrl("../../../qml/Greeter/graphics/session_icons")

        function init() {
            selectIndex(0); // break binding with text field
            tryCompare(LightDMService.prompts, "count", 1);
            selectedSpy.clear();
            respondedSpy.clear();
            teaseSpy.clear();
            emergencySpy.clear();
            infographicDataChangedSpy.clear();
            LightDMController.reset();
            LightDM.Sessions.iconSearchDirectories = [testIconDirectory];

            waitForRendering(view);
            var userList = findChild(view, "userList");
            tryCompare(userList, "movingInternally", false);
        }

        function cleanup() {
            keyboardVisibleCheckBox.checked = false;

            loader.itemDestroyed = false;
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            tryCompare(loader, "itemDestroyed", true);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
            removeTimeConstraintsFromSwipeAreas(loader.item);
            LightDMController.sessionMode = "single";
        }

        function setLightDMMockMode(mode) {
            LightDMController.userMode = mode;
            waitForRendering(root);
        }

        function setUsageMode(usageMode) {
            view.usageMode = usageMode;
            if (usageMode == "desktop") {
                view.multiUser = true;
                setLightDMMockMode("full");
                view.orientation = Qt.LandscapeOrientation;
            } else if (usageMode == "phone") {
                view.multiUser = false;
                setLightDMMockMode("single");
                view.orientation = Qt.PortraitOrientation;
                telepathyHelper.ready = true;
                telepathyHelper.emergencyCallsAvailable = true;
                LightDM.Greeter.authenticate("no-password");
                tryCompare(LightDMService.prompts, "count", 1);
            }
        }

        function swipeAwayCover(toTheRight) {
            if (toTheRight === undefined) {
                toTheRight = false;
            }

            tryCompare(view, "fullyShown", true);
            var touchY = view.height / 2;
            if (toTheRight) {
                touchFlick(view, 0, touchY, view.width, touchY);
            } else {
                touchFlick(view, view.width, touchY, 0, touchY);
            }
            var coverPage = findChild(view, "coverPage");
            tryCompare(coverPage, "showProgress", 0);
            waitForRendering(view);
        }

        function getIndexOf(name) {
            for (var i = 0; i < LightDM.Users.count; i++) {
                if (name === LightDM.Users.data(i, LightDM.UserRoles.NameRole)) {
                    return i;
                }
            }
            fail("Didn't find name")
            return -1;
        }

        function selectIndex(i) {
            var user = LightDM.Users.data(i, LightDM.UserRoles.NameRole);
            LightDM.Greeter.authenticate(user);

            var userList = findChild(view, "userList");
            var promptList = findChild(view, "promptList");

            view.currentIndex = i;
            tryCompare(promptList, "opacity", 1);
            tryCompare(userList, "movingInternally", false);
        }

        function selectUser(name) {
            var i = getIndexOf(name);
            selectIndex(i);
            return i;
        }

/* Desktop view tests (multiuser) */
        function test_sessionless_user_is_still_valid() {
            setUsageMode("desktop");
            var loginList = findChild(view, "loginList")

            /*
             * If a user has never logged in before, or, for some reason
             * has no sessionHint, ensure that the model returns the default
             * session and that the view respects this
             */
            selectUser("no-session");
            compare(LightDM.Users.data(loginList.currentIndex, LightDM.UserRoles.SessionRole), LightDM.Greeter.defaultSession);

            tryCompare(loginList, "currentSession", LightDM.Greeter.defaultSession);
        }

        function test_changingSessionSticksToUser() {
            setUsageMode("desktop");
            var loginList = findChild(view, "loginList");

            selectUser("invalid-session");
            tryCompare(loginList, "currentSession", "invalid");

            selectUser("has-password");
            tryCompare(loginList, "currentSession", "ubuntu");

            selectUser("invalid-session")
            tryCompare(loginList, "currentSession", "invalid");
        }

        function test_sessionIconsAreValid() {
            setUsageMode("desktop");
            LightDMController.sessionMode = "full";
            selectUser("has-password");

            // Test the login list icon is valid
            var sessionChooserButton = findChild(view, "sessionChooserButton");
            compare(sessionChooserButton.visible, true);

            var loginList = findChild(view, "loginList");
            var session = String(loginList.currentSession).toLowerCase();
            var icon = String(sessionChooserButton.icon);
            compare(icon.indexOf(session) > -1, true);

            // Test the session list icons are valid
            var lockscreen = findChild(view, "lockscreen");
            lockscreen.state = "SessionsList"
            var sessionsList = findChild(view, "sessionsList");
            tryCompare(sessionsList, "visible", true);
        }

        function test_choosingNewSessionChangesLoginListIcon() {
            // Ensure the default session is selected (Ubuntu)
            cleanup();
            setUsageMode("desktop");
            swipeAwayCover();

            LightDMController.sessionMode = "full";
            selectUser("has-password");

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            var icon = String(sessionChooserButton.icon);
            compare(icon.indexOf("ubuntu") > -1, true);

            tap(sessionChooserButton)
            for(var i = 0; i < LightDM.Sessions.count; i++) {
                var delegateName = "sessionDelegate" + String(i);
                var currentDelegate = findChild(view, delegateName);
                verify(currentDelegate);
                var sessionKey = LightDM.Sessions.data(i,LightDM.SessionRoles.KeyRole);
                if (sessionKey === "gnome-classic") {
                    waitForRendering(currentDelegate);
                    tap(currentDelegate);
                    waitForRendering(sessionChooserButton);
                    break;
                }
            }

            icon = String(sessionChooserButton.icon);
            compare(icon.indexOf("gnome") > -1, true,
                "Expected icon to contain gnome but it was " + icon);
        }

        function test_noSessionsDoesntBreakView() {
            setUsageMode("desktop");
            LightDMController.sessionMode = "none";
            compare(LightDM.Sessions.count, 0)
        }

        function test_sessionIconNotShownWithOneSession() {
            setUsageMode("desktop");
            LightDMController.sessionMode = "single";
            compare(LightDM.Sessions.count, 1);

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            tryCompare(sessionChooserButton, "visible", false);
        }

        function test_sessionIconNotShownWithActiveUser() {
            setUsageMode("desktop");
            selectUser("active");

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            tryCompare(sessionChooserButton, "visible", false);
        }

        function test_sessionIconShownWithMultipleSessions() {
            setUsageMode("desktop");
            LightDMController.sessionMode = "full";
            selectUser("has-password");

            var sessionChooserButton = findChild(view, "sessionChooserButton");
            tryCompare(sessionChooserButton, "visible", true);
        }

        function test_selected() {
            setUsageMode("desktop");
            swipeAwayCover();
            var delegate = findChild(view, "username2");
            tap(delegate);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], 2);
            compare(view.currentIndex, 0); // confirm we didn't change
        }

        function test_customBackground() {
            setUsageMode("desktop");
            var lockscreen = findChild(view, "lockscreen");
            var backgroundShade = findChild(lockscreen, "backgroundShade");

            verify(!view.hasCustomBackground);
            verify(!backgroundShade.visible);

            view.hasCustomBackground = true;
            verify(backgroundShade.visible);
        }

        function test_respondedWithPassword() {
            setUsageMode("desktop");
            swipeAwayCover();
            selectUser("has-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.isSecret);
            typeString("password");
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "password");
        }

        function test_respondedWithNonSecret() {
            setUsageMode("desktop");
            swipeAwayCover();
            selectUser("question-prompt");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(!greeterPrompt.isSecret);
            typeString("foo");
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "foo");
        }

        function test_fullyShown_data() {
            return [
                {tag: "multiuser", multiUser: true, usageMode: "desktop", results: [true, true, true, true]},
                {tag: "singleuser", multiUser: false, usageMode: "desktop", results: [true, false, true, false]},
                {tag: "multiuser", multiUser: true, usageMode: "phone", results: [true, true, true, true]},
                {tag: "singleuser", multiUser: false, usageMode: "phone", results: [true, false, true, false]}
            ]
        }

        function test_fullyShown(data) {
            setUsageMode(data.usageMode);
            view.multiUser = data.multiUser;
            tryCompare(view, "fullyShown", data.results[0]);
            tryCompare(view, "required", data.results[0]);
            swipeAwayCover();
            tryCompare(view, "fullyShown", data.results[1]);
            tryCompare(view, "required", data.results[1]);
            view.locked = true;
            tryCompare(view, "fullyShown", data.results[2]);
            tryCompare(view, "required", data.results[2]);
            view.locked = false;
            tryCompare(view, "fullyShown", data.results[3]);
            tryCompare(view, "required", data.results[3]);
        }

        function test_infoPrompt() {
            setUsageMode("desktop");
            selectUser("info-prompt");

            var infoLabel = findChild(view, "infoLabel0");
            compare(infoLabel.text, "Welcome to Unity Greeter");
            compare(infoLabel.textFormat, Text.PlainText);

            verify(findChild(view, "greeterPrompt1") != null);
        }

        function test_longInfoPrompt() {
            setUsageMode("desktop");
            selectUser("long-info-prompt");

            var infoLabel = findChild(view, "infoLabel0");
            compare(infoLabel.text, "Welcome to Unity Greeter\n\nWe like to annoy you with super ridiculously long messages.\nLike this one\n\nThis is the last line of a multiple line message.");
            verify(infoLabel.contentWidth > infoLabel.width);

            verify(findChild(view, "greeterPrompt1") != null);
        }

        function test_multiInfoPrompt() {
            setUsageMode("desktop");
            selectUser("multi-info-prompt");

            var infoLabel0 = findChild(view, "infoLabel0");
            compare(infoLabel0.text, "Welcome to Unity Greeter");

            var infoLabel1 = findChild(view, "infoLabel1");
            compare(infoLabel1.text, "This is an error");
            compare(infoLabel1.color, theme.palette.normal.negative);

            var infoLabel2 = findChild(view, "infoLabel2");
            compare(infoLabel2.text, "You should have seen three messages");

            verify(findChild(view, "greeterPrompt3") != null);
        }

        // Escape is used to reset the authentication, especially if PAM is unresponsive
        function test_escape() {
            setUsageMode("desktop");
            swipeAwayCover();
            var index = selectUser("has-password");
            selectedSpy.clear();
            view.locked = true;
            var promptField = findChild(view, "promptField");
            tap(promptField);
            verify(promptField.activeFocus);
            compare(promptField.opacity, 1);

            typeString("password");
            keyClick(Qt.Key_Enter);
            verify(promptField.activeFocus);
            compare(promptField.opacity, 0); // hidden by fakeLabel

            compare(selectedSpy.count, 0);
            keyClick(Qt.Key_Escape);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], index);

            selectIndex(index);
            var promptField = findChild(view, "promptField");
            verify(promptField.activeFocus);
            compare(promptField.opacity, 1);
        }

        function test_unicode() {
            setUsageMode("desktop");
            var index = selectUser("unicode");
            var label = findChild(view, "username" + index);
            tryCompare(label, "text", "가나다라마");
        }

        function test_authError() {
            setUsageMode("desktop");
            swipeAwayCover();
            var index = selectUser("auth-error");
            var greeterPrompt = findChild(view, "greeterPrompt1"); // after error message
            view.locked = true;
            compare(greeterPrompt.text, "Retry");
            tap(greeterPrompt);
            compare(respondedSpy.count, 0);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], index);
        }

        function test_noPassword() {
            setUsageMode("desktop");
            swipeAwayCover();
            selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            compare(greeterPrompt.text, "Log In");
            tap(greeterPrompt);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
        }

        function test_loginListNotCoveredByKeyboard() {
            setUsageMode("desktop");
            var loginList = findChild(view, "loginList");
            compare(loginList.height, view.height);

            // when the vkb shows up, loginList is moved up to remain fully uncovered

            keyboardVisibleCheckBox.checked = true;

            var halfway = (view.height - loginList.highlightedHeight) / 2;
            var halfwayWithOsk = halfway - view.inputMethodRect.height / 2;
            tryCompare(loginList, "boxVerticalOffset", halfwayWithOsk);

            var highlightItem = findChild(loginList, "highlightItem");
            tryCompareFunction( function() {
                var highlightRect = highlightItem.mapToItem(view, 0, 0, highlightItem.width, highlightItem.height);
                return highlightRect.y + highlightRect.height <= view.testKeyboard.y;
            }, true);

            // once the vkb goes away, loginList goes back to its full height

            keyboardVisibleCheckBox.checked = false;

            tryCompare(loginList, "boxVerticalOffset", halfway);
        }

        function test_passphrase() {
            setUsageMode("desktop");
            swipeAwayCover();
            var index = selectUser("has-password");
            var promptField = findChild(view, "promptField");

            verify(view.alphanumeric);
            compare(promptField.inputMethodHints & Qt.ImhDigitsOnly, 0);

            keyClick(Qt.Key_D);
            compare(promptField.text, "d");
        }

        function test_passcode() {
            setUsageMode("desktop");
            swipeAwayCover();
            var index = selectUser("has-pin");
            view.alphanumeric = false;

            var promptField = findChild(view, "promptField");
            compare(promptField.inputMethodHints & Qt.ImhDigitsOnly, Qt.ImhDigitsOnly);

            keyClick(Qt.Key_D);
            compare(promptField.text, "");

            keyClick(Qt.Key_0);
            keyClick(Qt.Key_0);
            keyClick(Qt.Key_0);
            keyClick(Qt.Key_0);
            compare(promptField.text, "0000");

            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "0000");

            compare(promptField.opacity, 0);
        }

        function test_loginListMovement_data() {
            return [
                {tag: "up", key: Qt.Key_Up, result: 1},
                {tag: "down", key: Qt.Key_Down, result: 3},
            ]
        }

        function test_loginListMovement(data) {
            setUsageMode("desktop");
            swipeAwayCover();
            selectIndex(2);
            selectedSpy.clear();

            keyClick(data.key);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], data.result);
        }

        function test_focusStaysActive() {
            setUsageMode("desktop");
            swipeAwayCover();
            selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);

            selectUser("has-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_D);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 0);
            compare(respondedSpy.count, 2);
            compare(respondedSpy.signalArguments[1][0], "d");
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 2);

            var index = selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            view.locked = true;
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 2);
            compare(selectedSpy.count, 1);
            compare(selectedSpy.signalArguments[0][0], index);
            verify(greeterPrompt.activeFocus);
            keyClick(Qt.Key_Enter);
            compare(selectedSpy.count, 1);

            selectUser("no-password");
            var greeterPrompt = findChild(view, "greeterPrompt0");
            verify(greeterPrompt.activeFocus);
        }

        function test_scrollChangesIndex() {
            /* Check if the index of the current user gets changed
             * if we scroll through the list.
             * Expected result: the list has moved at least by one
             * user and the index of the user is reported using the
             * selected signal in LoginList.qml
             * https://github.com/ubports/unity8/issues/397
             */
            setUsageMode("desktop");
            swipeAwayCover();
            var loginList = findChild(view, "loginList");
            // FIXME: Fix scrolling sensitivity (scrolling by -1 shouldn't move more than one user down)
            mouseWheel( loginList, loginList.width / 2, loginList.height / 2, 0, -1, null );
            selectedSpy.wait();
            tryVerify(function(){ return selectedSpy.signalArguments[0][0] > 0 });
        }

//        function test_dragChangesIndex() {
//            /* Check if the index of the current user gets changed
//             * if we drag the list or swipe.on it.
//             * Expected result: the list has moved at least by one
//             * user and the index of the user is reported using the
//             * selected signal in LoginList.qml
//             * https://github.com/ubports/unity8/issues/397
//             */
//            setUsageMode("desktop");
//            swipeAwayCover();
//            var loginList = findChild(view, "loginList");
//            // FIXME: Fix scrolling sensitivity (the number of scrolled users is randomly changing)
//            touchFlick(loginList, loginList.width/2, loginList.height/3, loginList.width/2, loginList.height/3 -units.gu(2.1));
//            selectedSpy.wait();
//            tryVerify(function(){ return selectedSpy.signalArguments[0][0] > 0 });
//        }

/* Mobile view tests */
        function test_tease_data() {
            return [
                {tag: "left", x: 0, offset: 0, count: 1},
                {tag: "leftWithOffsetPass", x: 10, offset: 10, count: 1},
                {tag: "leftWithOffsetFail", x: 9, offset: 10, count: 0},
                {tag: "right", x: view.width, offset: 0, count: 1},
            ]
        }
        function test_tease(data) {
            view.dragHandleLeftMargin = data.offset;
            tap(view, data.x, 0);
            tryCompare(teaseSpy, "count", data.count);
        }

        function test_respondedWithPin() {
            LightDM.Greeter.authenticate("has-pin");
            view.locked = true;
            view.alphanumeric = false;
            swipeAwayCover();
            typeString("1234");
            respondedSpy.wait();
            compare(respondedSpy.signalArguments[0][0], "1234");
        }

        function test_respondedWithPassphrase() {
            LightDM.Greeter.authenticate("has-password");
            view.locked = true;
            swipeAwayCover();
            typeString("test");
            keyClick(Qt.Key_Enter);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "test");
        }

        function test_respondedWithSwipe_data() {
            return [
                {tag: "left", toTheRight: false, hiddenX: -view.width},
                {tag: "right", toTheRight: true, hiddenX: view.width},
            ];
        }
        function test_respondedWithSwipe(data) {
            swipeAwayCover(data.toTheRight);
            var coverPage = findChild(view, "coverPage");
            compare(coverPage.x, data.hiddenX);
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "");
        }

        function test_emergencyCall_data() {
            return [
                {tag: "phone", available: true},
                {tag: "desktop", available: false},
            ];
        }
        function test_emergencyCall(data) {
            telepathyHelper.emergencyCallsAvailable = data.available;
            view.locked = true;
            swipeAwayCover();
            var emergencyCallLabel = findChild(view, "emergencyCallLabel");
            tap(emergencyCallLabel);
            if (!data.available) {
                expectFail("", "Bug 1616538 prevents us supporting conditional emergency button support");
            }
            compare(emergencyCallLabel.visible, data.available ? true : false);
            compare(emergencySpy.count, data.available ? 1 : 0);
        }

        function test_emergencyCallAvailability() {
            view.locked = true;
            var emergencyCallLabel = findChild(view, "emergencyCallLabel");
            verify(emergencyCallLabel.visible);

            telepathyHelper.emergencyCallsAvailable = false;
            telepathyHelper.ready = true;
            expectFail("", "Bug 1616538 prevents us supporting conditional emergency button support");
            verify(!emergencyCallLabel.visible);

            telepathyHelper.emergencyCallsAvailable = true;
            telepathyHelper.ready = false;
            verify(!emergencyCallLabel.visible);
        }

        function test_tryToUnlock() {
            var coverPage = findChild(view, "coverPage");
            tryCompare(coverPage, "showProgress", 1);
            compare(view.tryToUnlock(false), true);
            tryCompare(coverPage, "showProgress", 0);
            compare(view.tryToUnlock(false), false);
        }

        /*
            Regression test for https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1388359
            "User metrics can no longer be changed by double tap"
        */
        function test_doubleTapSwitchesToNextInfographic() {
            setUsageMode("phone");
            infographicDataChangedSpy.clear();
            var coverPage = findChild(view, "coverPage");
            verify(coverPage);

            var infographicPrivate = findInvisibleChild(coverPage, "infographicPrivate");
            verify(infographicPrivate);

            // wait for the UI to settle down before double tapping it
            tryCompare(infographicPrivate, "animating", false);

            var dataCircle = findChild(coverPage, "dataCircle");
            verify(dataCircle);

            mouseDoubleClickSequence(dataCircle);

            tryCompare(infographicDataChangedSpy, "count", 1);
        }

        function test_movesBackIntoPlaceWhenNotDraggedFarEnough() {
            var coverPage = findChild(view, "coverPage");

            var dragEvaluator = findInvisibleChild(coverPage, "edgeDragEvaluator");
            verify(dragEvaluator);

            // Make it easier to get a rejection/rollback. Otherwise would have to inject
            // a fake timer into dragEvaluator.
            // Afterall, we are testing if the CoverPage indeed moves back on a
            // rollback decision, not the drag evaluation itself.
            dragEvaluator.minDragDistance = dragEvaluator.maxDragDistance / 2;

            // it starts as fully shown
            compare(coverPage.x, 0);

            // then we drag it a bit
            var startX = coverPage.width - 1;
            var touchY = coverPage.height / 2;
            var dragXDelta = -(dragEvaluator.minDragDistance * 0.3);
            touchFlick(coverPage,
                       startX , touchY, // start pos
                       startX + dragXDelta, touchY, // end pos
                       true /* beginTouch */, false /* endTouch  */);

            // which should make it move a bit
            tryCompareFunction(function() {return coverPage.x < 0;}, true);

            // then we release it
            touchRelease(coverPage, startX + dragXDelta, touchY);

            // which should make it move back into its original position as it didn't move
            // far enough to have it hidden
            tryCompare(coverPage, "x", 0);
        }

        function test_dragToHide_data() {
            return [
                {tag: "left", startX: view.width * 0.95, endX: view.width * 0.1, hiddenX: -view.width},
                {tag: "right", startX: view.width * 0.1, endX: view.width * 0.95, hiddenX: view.width},
            ];
        }
        function test_dragToHide(data) {
            var coverPage = findChild(view, "coverPage");
            compare(coverPage.x, 0);
            compare(coverPage.visible, true);
            compare(coverPage.shown, true);
            compare(coverPage.showProgress, 1);
            compare(view.fullyShown, true);

            touchFlick(view,
                    data.startX, view.height / 2, // start pos
                    data.endX, view.height / 2); // end pos

            tryCompare(coverPage, "x", data.hiddenX);
            tryCompare(coverPage, "visible", false);
            tryCompare(coverPage, "shown", false);
            tryCompare(coverPage, "showProgress", 0);
            compare(view.fullyShown, false);
        }

        function test_hiddenViewRemainsHiddenAfterResize_data() {
            return [
                {tag: "left", startX: view.width * 0.95, endX: view.width * 0.1},
                {tag: "right", startX: view.width * 0.1, endX: view.width * 0.95},
            ];
        }
        function test_hiddenViewRemainsHiddenAfterResize(data) {
            touchFlick(view,
                    data.startX, view.height / 2, // start pos
                    data.endX, view.height / 2); // end pos

            var coverPage = findChild(view, "coverPage");
            tryCompare(coverPage, "x", data.tag == "left" ? -view.width : view.width);
            tryCompare(coverPage, "visible", false);
            tryCompare(coverPage, "shown", false);
            tryCompare(coverPage, "showProgress", 0);

            // flip dimensions to simulate an orientation change
            view.width = loader.height;
            view.height = loader.width;

            // All properties should remain consistent
            tryCompare(coverPage, "x", data.tag == "left" ? -view.width : view.width);
            tryCompare(coverPage, "visible", false);
            tryCompare(coverPage, "shown", false);
            tryCompare(coverPage, "showProgress", 0);
        }

        // Make sure that if user has a mouse, they can still get rid of cover page
        function test_mouseClickHidesCoverPage() {
            var coverPage = findChild(view, "coverPage");

            verify(coverPage.shown);
            mouseClick(coverPage, coverPage.width/2, coverPage.height - units.gu(2));
            verify(!coverPage.shown);
        }

        function test_showErrorMessage() {
            var coverPage = findChild(view, "coverPage");
            var swipeHint = findChild(coverPage, "swipeHint");
            var errorMessageAnimation = findInvisibleChild(coverPage, "errorMessageAnimation");

            view.showErrorMessage("hello");
            compare(swipeHint.text, "《    hello    》");
            verify(errorMessageAnimation.running);
            verify(swipeHint.opacityAnimation.running);

            errorMessageAnimation.complete();
            swipeHint.opacityAnimation.complete();
            tryCompare(swipeHint, "text", "《    " + i18n.tr("Unlock") + "    》");
        }

        function test_keepPasswordOnRotation() {
            /* Check if the password is kept when rotating
             * the screen from portrait to landscape in mobile.
             */
            setUsageMode("phone");
            LightDM.Greeter.authenticate("has-password");
            view.locked = true;
            swipeAwayCover();

            let greeterPrompt = findChild(view, "greeterPrompt0");
            tryCompare(greeterPrompt, "enteredText", "");
            typeString("test");
            tryCompare(greeterPrompt, "enteredText", "test");
            view.orientation = Qt.LandscapeOrientation;
            tryCompare(greeterPrompt, "enteredText", "test");
        }

        function test_infographicsShownOnRotation_data() {
            return [
                {
                    tag: "phone-portrait-singleuser",
                    multiUser: false,
                    usageMode: "phone",
                    orientation: Qt.PortraitOrientation,
                    coverPage: true,
                    lockscreen: false
                },
                {
                    tag: "phone-portrait-multiuser",
                    multiUser: true,
                    usageMode: "phone",
                    orientation: Qt.PortraitOrientation,
                    coverPage: false,
                    lockscreen: false
                },
                {
                    tag: "phone-landscape-singleuser",
                    multiUser: false,
                    usageMode: "phone",
                    orientation: Qt.LandscapeOrientation,
                    coverPage: true,
                    lockscreen: false
                },
                {
                    tag: "phone-landscape-multiuser",
                    multiUser: true,
                    usageMode: "phone",
                    orientation: Qt.LandscapeOrientation,
                    coverPage: false,
                    lockscreen: false
                },
                {
                    tag: "tablet-landscape-singleuser",
                    multiUser: false,
                    usageMode: "tablet",
                    orientation: Qt.LandscapeOrientation,
                    coverPage: true,
                    lockscreen: false
                },
                {
                    tag: "tablet-landscape-multiuser",
                    multiUser: true,
                    usageMode: "tablet",
                    orientation: Qt.LandscapeOrientation,
                    coverPage: false,
                    lockscreen: true
                },
                {
                    tag: "tablet-portrait-singleuser",
                    multiUser: false,
                    usageMode: "tablet",
                    orientation: Qt.PortraitOrientation,
                    coverPage: true,
                    lockscreen: false
                },
                {
                    tag: "tablet-portrait-multiuser",
                    multiUser: true,
                    usageMode: "tablet",
                    orientation: Qt.PortraitOrientation,
                    coverPage: false,
                    lockscreen: false
                },
                {
                    tag: "desktop-singleuser",
                    multiUser: false,
                    usageMode: "desktop",
                    orientation: Qt.LandscapeOrientation,
                    coverPage: false,
                    lockscreen: true
                },
                {
                    tag: "desktop-multiuser",
                    multiUser: true,
                    usageMode: "desktop",
                    orientation: Qt.LandscapeOrientation,
                    coverPage: false,
                    lockscreen: true
                }
            ]
        }

        function test_infographicsShownOnRotation(data) {
            /* Check if infographics is shown in the correct
             * places. This test runs in all the combinations
             * of orientation and usage mode.
             */
            setUsageMode(data.usageMode);
            view.orientation = data.orientation;
            view.multiUser = data.multiUser;
            view.locked = true;

            let coverPage = findChild(view, "coverPage");
            let lockscreen = findChild(view, "lockscreen");
            let coverPageInfographics = findChild(coverPage, "infographicsLoader");
            let lockscreenInfographics = findChild(lockscreen, "infographicsLoader");
            verify(coverPageInfographics);
            verify(lockscreenInfographics);

            tryCompare(coverPageInfographics, "active", data.coverPage);
            swipeAwayCover();
            tryCompare(lockscreenInfographics, "active", data.lockscreen);
        }
    }
}
