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
/*!
 \brief A filter for the physical keys on the device

 A filter to handle events triggered by pressing physical keys on a device.
 Keys included are
    * Volume Increase
    * Volume Decrease
    * Power

 This allows for handling the following events
    * Volume Decreases/Increases
    * Screenshots

*/

QtObject {
    id: root

    signal volumeDownPressed()
    signal volumeUpPressed()
    signal screenshotPressed()

    property bool powerKeyPressed: false

    property bool aVolumeKeyWasReleased: true
    property bool volumeDownKeyPressed: false
    property bool volumeUpKeyPressed: false

    function onKeyPressed(key) {
        if (key == Qt.Key_PowerDown || key == Qt.Key_PowerOff) {
            powerKeyPressed = true;
        }
        else if (key == Qt.Key_VolumeDown) {
            volumeDownKeyPressed = true;
        }
        else if (key == Qt.Key_VolumeUp) {
            volumeUpKeyPressed = true;
        }

        if (volumeDownKeyPressed && volumeUpKeyPressed) {
            if (aVolumeKeyWasReleased) {
                bothVolumeKeysPressed();
            }
            aVolumeKeyWasReleased = false;
        }
        else if (volumeDownKeyPressed) {
            if (powerKeyPressed) {
                screenshotPressed();
            } else {
                volumeDownPressed();
            }
        }
        else if (volumeUpKeyPressed) {
            volumeUpPressed();
        }
    }

    function onKeyReleased(key) {
        if (key == Qt.Key_PowerDown || key == Qt.Key_PowerOff) {
            powerKeyPressed = false;
        }
        else if (key == Qt.Key_VolumeDown) {
            volumeDownKeyPressed = false;
            aVolumeKeyWasReleased = false;
        }
        else if (key == Qt.Key_VolumeUp) {
            volumeUpKeyPressed = false;
            aVolumeKeyWasReleased = true;
        }
    }
}
