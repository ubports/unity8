/*
 * Copyright (C) 2014 Canonical, Ltd.
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

    PhysicalKeysMapper {
        id: physicalKeysMapper
    }

    SignalSpy {
        id: powerSpy
        target: physicalKeysMapper
        signalName: "powerKeyLongPress"
    }

    function cleanup() {
        physicalKeysMapper.onKeyReleased({ key: Qt.Key_PowerDown });
        physicalKeysMapper.onKeyReleased({ key: Qt.Key_VolumeDown });
        physicalKeysMapper.onKeyReleased({ key: Qt.Key_VolumeUp });

        powerSpy.clear();
    }

    function test_LongPressPowerButton() {
        physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown });

        expectFailContinue("", "Power signal should not be emitted within a second");
        powerSpy.wait(1000);
        powerSpy.clear();

        physicalKeysMapper.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true });
        powerSpy.wait(1500);
    }

    function test_ScreenshotButtons() {
        /* Behavior when VolumeUp is pressed 1st */
        physicalKeysMapper.onKeyPressed({ key: Qt.Key_VolumeUp });
        physicalKeysMapper.onKeyPressed({ key: Qt.Key_VolumeDown });
        compare(physicalKeysMapper.screenshotPressed, true);
        compare(physicalKeysMapper.volumeDownPressed, false);

        physicalKeysMapper.onKeyReleased({ key: Qt.Key_VolumeUp });
        physicalKeysMapper.onKeyReleased({ key: Qt.Key_VolumeDown });

        /* Behavior when VolumeDown is pressed 1st */
        physicalKeysMapper.onKeyPressed({ key: Qt.Key_VolumeDown });
        compare(physicalKeysMapper.volumeDownPressed, true);
        physicalKeysMapper.onKeyPressed({ key: Qt.Key_VolumeUp });
        compare(physicalKeysMapper.screenshotPressed, true);
    }

    function test_VolumeDownButton() {
        compare(physicalKeysMapper.volumeDownPressed, false);
        physicalKeysMapper.onKeyPressed({ key: Qt.Key_VolumeDown });
        compare(physicalKeysMapper.volumeDownPressed, true);
    }

    function test_VolumeUpButton() {
        compare(physicalKeysMapper.volumeUpPressed, false);
        physicalKeysMapper.onKeyPressed({ key: Qt.Key_VolumeUp });
        compare(physicalKeysMapper.volumeUpPressed, true);
    }
}
