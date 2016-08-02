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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import "../../qml"

Item {
    id: root
    width: units.gu(80)
    height: units.gu(70)

    DisabledScreenNotice {
        id: touchScreenPad
        anchors.fill: parent
        anchors.rightMargin: units.gu(40)

        // Mock some things here
        property int internalGu: units.gu(1)
        property var applicationArguments: {
            deviceName: "mako"
        }

        screen: QtObject {
            property int orientation: {
                switch (orientationSelector.selectedIndex) {
                case 0:
                    return Qt.PortraitOrientation;
                case 1:
                    return Qt.LandscapeOrientation;
                case 2:
                    return Qt.InvertedPortraitOrientation;
                case 3:
                    return Qt.InvertedLandscapeOrientation;
                }
            }
        }
        orientationLock: QtObject {
            property bool enabled: orientationLockCheckBox.checked
        }
    }

    Column {
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: units.gu(40)
        spacing: units.gu(1)

        ItemSelector {
            id: orientationSelector
            model: ["Portrait", "Landscape", "InvertedPortrait", "InvertedLandscape"]
            selectedIndex: 0
        }

        RowLayout {
            CheckBox {
                id: orientationLockCheckBox
                checked: false
            }
            Label {
                text: "Rotation lock"
                Layout.fillWidth: true
            }
        }
        Button {
            text: "Reset first run settings"
            onClicked: {
                print("foooo")
                var settings = testCase.findInvisibleChild(touchScreenPad, "firstRunSettings");
                print("have settigs:", settings)
                settings.tutorialHasRun = false;
            }
        }
        Button {
            text: "Run tutorial now"
            onClicked: {
                var touchPad = testCase.findChild(touchScreenPad, "virtualTouchPad")
                touchPad.runTutorial();
            }
        }
    }

    UnityTestCase {
        id: testCase
        name: "DisabledScreenNotice"
        when: windowShown

        function test_rotation_data() {
            return [
                {tag: "portrait", selectedOrientation: 0, expectedAngle: 0},
                {tag: "landscape", selectedOrientation: 1, expectedAngle: 270},
                {tag: "invertedportrait", selectedOrientation: 2, expectedAngle: 180},
                {tag: "invertetlandscape", selectedOrientation: 3, expectedAngle: 90}
            ];
        }

        function test_rotation(data) {
            var content = findChild(touchScreenPad, "contentContainer");

            var oldRotation = content.rotation;

            // Turn on orientation lock
            orientationLockCheckBox.checked = true;

            // simulate the rotation
            orientationSelector.selectedIndex = data.selectedOrientation;

            // Make sure it is still in the old rotation (as we have the lock turned on)
            expectFail("", "Rotation lock set. Expecting automatic rotation to fail.");
            tryCompareFunction(function() { return content.rotation != oldRotation; }, true, 300);

            // Now uncheck the rotation lock
            orientationLockCheckBox.checked = false;

            // And make sure it catches up to the expected angle
            tryCompare(content, "rotation", data.expectedAngle);
        }

        function test_tutorial() {
            var oskButton = findChild(touchScreenPad, "oskButton");
            var leftButton = findChild(touchScreenPad, "leftButton");
            var rightButton = findChild(touchScreenPad, "rightButton");
            var touchPad = findChild(touchScreenPad, "virtualTouchPad")
            var tutorial = findInvisibleChild(touchScreenPad, "tutorialAnimation")
            var tutorialFinger1 = findChild(touchScreenPad, "tutorialFinger1");
            var tutorialFinger2 = findChild(touchScreenPad, "tutorialFinger2");
            var tutorialLabel = findChild(touchScreenPad, "tutorialLabel");
            var tutorialImage = findChild(touchScreenPad, "tutorialImage");

            // run the tutorial
            touchPad.runTutorial();
            tryCompare(tutorial, "running", true)

            // Wait for it to pause
            tryCompare(tutorial, "paused", true)

            // Click somewhere to make it continue
            mouseClick(root, root.width / 2, root.height /2)
            tryCompare(tutorial, "paused", false)

            // Wait for it to finish
            tryCompare(tutorial, "running", false, 60000)

            // Make sure after the tutorial, all the visible states are proper
            tryCompare(oskButton, "visible", true)
            tryCompare(leftButton, "visible", true)
            tryCompare(rightButton, "visible", true)

            tryCompare(tutorialFinger1, "visible", false)
            tryCompare(tutorialFinger2, "visible", false)
            tryCompare(tutorialImage, "visible", false)
            tryCompare(tutorialLabel, "visible", false)
        }
    }
}
