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

TestCase {
    name: "PhysicalKeysMapper"

    property var physicalKeysMapper: loader.item

    Loader {
        // Using a Loader here to make sure mapper state is coherent
        // regardless of unmatched KeyPress and KeyRelease events
        id: loader
        active: false
        sourceComponent: PhysicalKeysMapper { }
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

    function init() {
        Powerd.setStatus(Powerd.On, Powerd.Unknown);
        loader.active = true;
        tryCompare(loader.status == Loader.Ready);
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
}
