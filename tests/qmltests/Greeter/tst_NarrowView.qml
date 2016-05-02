/*
 * Copyright 2014 Canonical Ltd.
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
import ".."
import "../../../qml/Greeter"
import LightDM.IntegratedLightDM 0.1 as LightDM
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(90)
    height: units.gu(80)

    Component.onCompleted: theme.name = "Ubuntu.Components.Themes.SuruDark" // use the same theme as the real shell

    Row {
        anchors.fill: parent
        Loader {
            id: loader
            width: root.width - controls.width
            height: parent.height

            property bool itemDestroyed: false
            sourceComponent: Component {
                NarrowView {
                    background: Qt.resolvedUrl("../../../qml/graphics/phone_background.jpg")
                    userModel: LightDM.Users
                    infographicModel: LightDM.Infographic

                    launcherOffset: parseFloat(launcherOffsetField.text)
                    currentIndex: parseInt(currentIndexField.text, 10)
                    delayMinutes: parseInt(delayMinutesField.text, 10)
                    backgroundTopMargin: parseFloat(backgroundTopMarginField.text)
                    locked: lockedCheckBox.checked
                    alphanumeric: alphanumericCheckBox.checked

                    Component.onDestruction: {
                        loader.itemDestroyed = true
                    }

                    onSelected: {
                        currentIndexField.text = index;
                    }
                }
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
                        text: "Show Last Chance"
                        onClicked: loader.item.showLastChance()
                    }
                }
                Row {
                    Button {
                        text: "Hide"
                        onClicked: loader.item.hide()
                    }
                }
                Row {
                    Button {
                        text: "Reset"
                        onClicked: loader.item.reset()
                    }
                }
                Row {
                    Button {
                        text: "Show Message"
                        onClicked: loader.item.showMessage(messageField.text)
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
                        onClicked: loader.item.showPrompt(promptField.text, isSecretCheckBox.checked, isDefaultPromptCheckBox.checked)
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
                    CheckBox {
                        id: isDefaultPromptCheckBox
                    }
                    Label {
                        text: "default"
                    }
                }
                Row {
                    Button {
                        text: "Authenticated"
                        onClicked: {
                            if (successCheckBox.checked) {
                                loader.item.notifyAuthenticationSucceeded();
                            } else {
                                loader.item.notifyAuthenticationFailed();
                            }
                        }
                    }
                    CheckBox {
                        id: successCheckBox
                    }
                    Label {
                        text: "success"
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
                        id: backgroundTopMarginField
                        width: units.gu(10)
                        text: "0"
                    }
                    Label {
                        text: "backgroundTopMargin"
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
                        id: alphanumericCheckBox
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
                    Button {
                        text: "Reload View"
                        onClicked: {
                            loader.active = false;
                            loader.active = true;
                        }
                    }
                }
            }
        }
    }

    Binding {
        target: LightDM.Infographic
        property: "username"
        value: "single"
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
        name: "NarrowView"
        when: windowShown

        property Item view: loader.status === Loader.Ready ? loader.item : null

        function init() {
            view.currentIndex = 0; // break binding with text field

            selectedSpy.clear();
            respondedSpy.clear();
            teaseSpy.clear();
            emergencySpy.clear();
            infographicDataChangedSpy.clear();
        }

        function cleanup() {
            loader.itemDestroyed = false;
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            tryCompare(loader, "itemDestroyed", true);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(loader.item);
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

        function enterPin(pin) {
            for (var i = 0; i < pin.length; ++i) {
                var character = pin.charAt(i);
                var button = findChild(view, "pinPadButton" + character);
                tap(button);
            }
        }

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
            compare(teaseSpy.count, data.count);
        }

        function test_respondedWithPin() {
            view.locked = true;
            swipeAwayCover();
            enterPin("1234");
            compare(respondedSpy.count, 1);
            compare(respondedSpy.signalArguments[0][0], "1234");
        }

        function test_respondedWithPassphrase() {
            view.locked = true;
            view.alphanumeric = true;
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

        function test_emergencyCall() {
            view.locked = true;
            swipeAwayCover();
            var emergencyCallLabel = findChild(view, "emergencyCallLabel");
            tap(emergencyCallLabel);
            compare(emergencySpy.count, 1);
        }

        function test_fullyShown() {
            tryCompare(view, "fullyShown", true);
            swipeAwayCover();
            tryCompare(view, "fullyShown", false);
            view.locked = true;
            tryCompare(view, "fullyShown", true);
            view.locked = false;
            tryCompare(view, "fullyShown", false);
        }

        function test_required() {
            tryCompare(view, "required", true);
            swipeAwayCover();
            tryCompare(view, "required", false);
            view.locked = true;
            tryCompare(view, "required", true);
            view.locked = false;
            tryCompare(view, "required", false);
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
            var infographicPrivate = findInvisibleChild(view, "infographicPrivate");
            verify(infographicPrivate);

            // wait for the UI to settle down before double tapping it
            tryCompare(infographicPrivate, "animating", false);

            var dataCircle = findChild(view, "dataCircle");
            verify(dataCircle);

            tap(dataCircle);
            wait(1);
            tap(dataCircle);

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
    }
}
