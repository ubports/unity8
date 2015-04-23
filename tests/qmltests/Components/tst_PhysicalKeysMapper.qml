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

import QtQuick 2.0
import QtTest 1.0
import "../../../qml/Components"

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
        id: volumeDownSpy
        target: physicalKeysMapper
        signalName: "volumeDownTriggered"
    }

    SignalSpy {
        id: volumeUpSpy
        target: physicalKeysMapper
        signalName: "volumeUpTriggered"
    }

    SignalSpy {
        id: screenshotSpy
        target: physicalKeysMapper
        signalName: "screenshotTriggered"
    }

    function init() {
        loader.active = true;
        tryCompare(loader.status == Loader.Ready);
    }

    function cleanup() {
        loader.active = false;
        powerSpy.clear();
        volumeDownSpy.clear();
        volumeUpSpy.clear();
        screenshotSpy.clear();
    }

    function test_powerKeyLongPressed() {
        physicalKeysMapper.powerKeyLongPressTime = 500;

        physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: false });

        for (var i = 0; i < 3; ++i) {
            wait(10);
            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true});
        }

        // powerKeyLongPressed should not have been emitted yet.
        compare(powerSpy.count, 0);

        for (var i = 0; i < 10; ++i) {
            wait(50);
            physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true});
        }

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

        wait(100);
        compare(volumeUpSpy.count, 0);
        compare(volumeDownSpy.count, 0);
    }

    function test_volumeButton_data() {
        return [
            { tag: "Down", key: Qt.Key_VolumeDown, spy: volumeDownSpy },
            { tag: "Up", key: Qt.Key_VolumeUp, spy: volumeUpSpy },
        ];
    }

    function test_volumeButton(data) {
        physicalKeysMapper.onKeyPressed({ key: data.key });

        wait(100);
        compare(data.spy.count, 0);

        physicalKeysMapper.onKeyReleased({ key: data.key });
        data.spy.wait();

        physicalKeysMapper.onKeyPressed({ key: data.key });
        physicalKeysMapper.onKeyPressed({ key: data.key, isAutoRepeat: true });
        data.spy.wait();
    }
}
