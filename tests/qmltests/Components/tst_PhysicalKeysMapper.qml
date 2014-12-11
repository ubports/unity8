/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * Authors:
 *   Josh Arenson <joshua.arenson@canonical.com>
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
import Unity.Test 0.1 as UT

Item {

    property int onBothVolumeKeysPressedCount: 0
    property int onPowerKeyLongPressCount: 0
    property int onScreenshotPressedCount: 0
    property int onVolumeDownPressedCount: 0
    property int onVolumeUpPressedCount: 0

    PhysicalKeysMapper {
        id: physicalKeysMapper

        onBothVolumeKeysPressed: onBothVolumeKeysPressedCount += 1
        onPowerKeyLongPress: onPowerKeyLongPressCount += 1
        onScreenshotPressed: onScreenshotPressedCount += 1
        onVolumeDownPressed: onVolumeDownPressedCount += 1
        onVolumeUpPressed: onVolumeUpPressedCount += 1
    }

    UT.UnityTestCase {
        name: "PhysicalKeyMapper"
        when: windowShown

        function cleanup() {
            physicalKeysMapper.onKeyReleased(Qt.Key_PowerDown);
            physicalKeysMapper.onKeyReleased(Qt.Key_PowerOff);
            physicalKeysMapper.onKeyReleased(Qt.Key_VolumeDown);
            physicalKeysMapper.onKeyReleased(Qt.Key_VolumeUp);

            onBothVolumeKeysPressedCount = 0;
            onPowerKeyLongPressCount = 0;
            onScreenshotPressedCount = 0;
            onVolumeDownPressedCount = 0;
            onVolumeUpPressedCount = 0;
        }

        function test_BothVolumeKeysSimultaneously() {
            physicalKeysMapper.onKeyPressed(Qt.Key_VolumeDown);
            physicalKeysMapper.onKeyPressed(Qt.Key_VolumeUp);

            compare(onBothVolumeKeysPressedCount, 1);

            // Simulate holding the keys down
            wait(3000);
            compare(onBothVolumeKeysPressedCount, 1);
        }

        function test_LongPressPowerButton() {
            physicalKeysMapper.onKeyPressed(Qt.Key_PowerDown);
            wait(3000);

            compare(onPowerKeyLongPressCount, 1);
        }

        function test_ScreenshotButtons() {
            physicalKeysMapper.onKeyPressed(Qt.Key_PowerDown);
            physicalKeysMapper.onKeyPressed(Qt.Key_VolumeDown);

            compare(onScreenshotPressedCount, 1);
            compare(onVolumeDownPressedCount, 0);

            wait(3000);
            compare(onScreenshotPressedCount, 1);
            compare(onVolumeDownPressedCount, 0);
        }

        function test_VolumeDownButton() {
            physicalKeysMapper.onKeyPressed(Qt.Key_VolumeDown);
            compare(onVolumeDownPressedCount, 1);
        }

        function test_VolumeUpButton() {
            physicalKeysMapper.onKeyPressed(Qt.Key_VolumeUp);
            compare(onVolumeUpPressedCount, 1);
        }
    }
}
