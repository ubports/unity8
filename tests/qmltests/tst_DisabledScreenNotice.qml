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
        anchors.fill: parent
        anchors.leftMargin: units.gu(40)

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
    }

    UnityTestCase {
        id: testCase
        name: "DisabledScreenNotice"
        when: windowShown

        function test_mouseAreaHidesOnFirstTap() {
            var noticeArea = findChild(touchScreenPad, "infoNoticeArea")
            compare(noticeArea.visible, true)
            tap(root)
            tryCompare(noticeArea, "visible", false)
        }

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
    }
}
