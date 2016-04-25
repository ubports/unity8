/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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
import "../../../qml/Components"
import Powerd 0.1
import Utils 0.1

Item {
    width: 100
    height: 100

    property var physicalKeysMapper: loader.item

    WindowInputFilter {
        Keys.onPressed: physicalKeysMapper.onKeyPressed(event, lastInputTimestamp);
        Keys.onReleased: physicalKeysMapper.onKeyReleased(event, lastInputTimestamp);
    }

    Loader {
        // Using a Loader here to make sure mapper state is coherent
        // regardless of unmatched KeyPress and KeyRelease events
        id: loader
        active: false
        sourceComponent: PhysicalKeysMapper { }
    }

    Item {
        id: inputCatcher
        focus: true

        property var pressedKeys: []
        property var releasedKeys: []

        Keys.onPressed: {
            inputCatcher.pressedKeys.push(event.key);
        }
        Keys.onReleased: {
            inputCatcher.releasedKeys.push(event.key);
        }
    }

    SignalSpy {
        id: powerSpy
        target: physicalKeysMapper
        signalName: "powerKeyLongPressed"
    }

    SignalSpy {
        id: screenshotSpy
        target: physicalKeysMapper
        signalName: "screenshotTriggered"
    }

    TestCase {
        name: "PhysicalKeysMapper"
        when: windowShown

        function init() {
            Powerd.setStatus(Powerd.On, Powerd.Unknown);
            loader.active = true;
            tryCompare(loader.status == Loader.Ready);
            inputCatcher.pressedKeys = [];
            inputCatcher.releasedKeys = [];
        }

        function cleanup() {
            loader.active = false;
            powerSpy.clear();
            screenshotSpy.clear();
        }

        function test_powerKeyLongPressed_data() {
            return [
                { tag: "screenOn", status: Powerd.On },
                { tag: "screenOff", status: Powerd.Off },
            ];
        }

        function test_powerKeyLongPressed(data) {
            Powerd.setStatus(data.status, Powerd.Unknown);
            physicalKeysMapper.powerKeyLongPressTime = 500;

            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: false }, 100);

            // After the first key press the screen is always on
            // and the rest of keypresses are auto repeat
            Powerd.setStatus(Powerd.On, Powerd.Unknown);

            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true}, 300);
            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true}, 400);
            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true}, 500);
            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true}, 599);

            // powerKeyLongPressed should not have been emitted yet.
            compare(powerSpy.count, 0);

            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true}, 600);

            compare(powerSpy.count, 1);

            // Confirm we only emit once
            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true}, 601);
            compare(powerSpy.count, 1);
        }

        function test_screenshotButtons_data() {
            return [
                { tag: "UpFirst", first: Qt.Key_VolumeUp, second: Qt.Key_VolumeDown },
                { tag: "DownFirst", first: Qt.Key_VolumeDown, second: Qt.Key_VolumeUp },
            ];
        }

        function test_screenshotButtons(data) {
            physicalKeysMapper.onKeyPressed({ key: data.first });
            physicalKeysMapper.onKeyPressed({ key: data.second });
            screenshotSpy.wait();
            physicalKeysMapper.onKeyReleased({ key: data.first });
            physicalKeysMapper.onKeyReleased({ key: data.second });
            compare(screenshotSpy.count, 1);
        }

        function test_altIsDispatchedOnRelease() {
            // Press alt, make sure it does *not* end up in inputCatcher (aka, the focused app)
            keyPress(Qt.Key_Alt, Qt.NoModifier)
            compare(inputCatcher.pressedKeys.length, 0);
            // Now release alt. It should cause the previous Alt press to be dispatched along with the release
            keyRelease(Qt.Key_Alt, Qt.NoModifier);
            compare(inputCatcher.pressedKeys.length, 1);
            compare(inputCatcher.pressedKeys[0], Qt.Key_Alt);
            compare(inputCatcher.releasedKeys.length, 1);
            compare(inputCatcher.releasedKeys[0], Qt.Key_Alt);
        }

        function test_altIsNotDispatchedOnAltTab() {
            // Press alt, make sure it does *not* end up in inputCatcher (aka, the focused app)
            inputCatcher.pressedKeys = [];
            keyPress(Qt.Key_Alt, Qt.NoModifier)
            compare(inputCatcher.pressedKeys.length, 0);
            // Now also press tab. As this should trigger the spread, neither of them should end up in the app
            keyPress(Qt.Key_Tab, Qt.NoModifier)
            compare(inputCatcher.pressedKeys.length, 0);

            // Also the release events should not be dispatched to the app
            keyRelease(Qt.Key_Tab, Qt.NoModifier);
            keyRelease(Qt.Key_Alt, Qt.NoModifier);
            compare(inputCatcher.pressedKeys.length, 0);
            compare(inputCatcher.releasedKeys.length, 0);
        }

        function test_altComboIsDispatched() {
            inputCatcher.pressedKeys = [];
            // Press alt, make sure it does *not* yet end up in inputCatcher (aka, the focused app)
            keyPress(Qt.Key_Alt, Qt.NoModifier)
            compare(inputCatcher.pressedKeys.length, 0);
            // Now press F in order to opening the File menu (Alt+F), now the app should get the full combo
            keyPress(Qt.Key_F, Qt.NoModifier)
            compare(inputCatcher.pressedKeys.length, 2);
            compare(inputCatcher.pressedKeys[0], Qt.Key_Alt);
            compare(inputCatcher.pressedKeys[1], Qt.Key_F);

            // release them both, both are supposed to end up in the app
            keyRelease(Qt.Key_F, Qt.NoModifier);
            keyRelease(Qt.Key_Alt, Qt.NoModifier);
            compare(inputCatcher.releasedKeys.length, 2);
        }
    }
}
