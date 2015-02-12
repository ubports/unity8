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

    property int onPowerKeyLongPressCount: 0
    property int initialLongPressTimerValue

    PhysicalKeysMapper {
        id: physicalKeysMapper

        onPowerKeyLongPress: onPowerKeyLongPressCount += 1
    }

    function initTestCase() {
        initialLongPressTimerValue = physicalKeysMapper.powerKeyLongPressTimeMs
    }

    function cleanup() {
        physicalKeysMapper.onKeyReleased(Qt.Key_PowerDown);
        physicalKeysMapper.onKeyReleased(Qt.Key_PowerOff);
        physicalKeysMapper.onKeyReleased(Qt.Key_VolumeDown);
        physicalKeysMapper.onKeyReleased(Qt.Key_VolumeUp);

        onPowerKeyLongPressCount = 0;

        physicalKeysMapper.powerKeyLongPressTimeMs = initialLongPressTimerValue
    }

    function test_LongPressPowerButton() {
        // Delays chosen are lowest reliable values
        physicalKeysMapper.powerKeyLongPressTimeMs = 2
        physicalKeysMapper.onKeyPressed(Qt.Key_PowerDown);
        wait(15);

        compare(onPowerKeyLongPressCount, 1);
    }

    function test_ScreenshotButtons() {
        /* Behavior when Power is pressed 1st */
        physicalKeysMapper.onKeyPressed(Qt.Key_PowerDown);
        physicalKeysMapper.onKeyPressed(Qt.Key_VolumeDown);
        compare(physicalKeysMapper.screenshotPressed, true);
        compare(physicalKeysMapper.volumeDownPressed, false);

        physicalKeysMapper.onKeyReleased(Qt.Key_PowerDown);
        physicalKeysMapper.onKeyReleased(Qt.Key_VolumeDown);

        /* Behavior when VolumeDown is pressed 1st */
        physicalKeysMapper.onKeyPressed(Qt.Key_VolumeDown);
        compare(physicalKeysMapper.volumeDownPressed, true);
        physicalKeysMapper.onKeyPressed(Qt.Key_PowerDown);
        compare(physicalKeysMapper.screenshotPressed, true);
    }

    function test_VolumeDownButton() {
        compare(physicalKeysMapper.volumeDownPressed, false);
        physicalKeysMapper.onKeyPressed(Qt.Key_VolumeDown);
        compare(physicalKeysMapper.volumeDownPressed, true);
    }

    function test_VolumeUpButton() {
        compare(physicalKeysMapper.volumeUpPressed, false);
        physicalKeysMapper.onKeyPressed(Qt.Key_VolumeUp);
        compare(physicalKeysMapper.volumeUpPressed, true);
    }
}
