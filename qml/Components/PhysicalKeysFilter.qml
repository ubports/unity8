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
/*!
 \brief A filter for the physical keys on the device

 A filter to handle events triggered by pressing physical keys on a device.
 Keys included are
    * Volume Decrease
    * Volume Increase
    * Power

 This allows for handling the following events
    * Volume Decreases/Increases
    * Screenshots

*/

QtObject {
    id: root

    signal bothVolumeKeysPressed();
    signal powerKeyLongPress();
    signal screenshotPressed();
    signal volumeDownPressed();
    signal volumeUpPressed();

    property bool eventAccepted: false

    property bool aPowerKeyWasReleased: true
    property bool powerKeyPressed: false

    property bool aVolumeKeyWasReleased: true
    property bool volumeDownKeyPressed: false
    property bool volumeUpKeyPressed: false

    // FIXME: event.isAutoRepeat is always false on Nexus 4.
    // So we use powerKeyTimer.running to avoid the PowerOff key repeat
    // https://launchpad.net/bugs/1349416
    property variant pklpt: Timer {
        id: powerKeyLongPressTimer

        interval: 2000
        repeat: false
        triggeredOnStart: false

        onTriggered: powerKeyLongPress();
    }

    function onKeyPressed(key) {
        /* Determine what key was pressed */
        if (key == Qt.Key_PowerDown || key == Qt.Key_PowerOff) {
            if (!powerKeyLongPressTimer.running) {
                powerKeyLongPressTimer.restart();
            }
            eventAccepted = true;
            powerKeyPressed = true;
        } else if (key == Qt.Key_VolumeDown) {
            eventAccepted = true;
            volumeDownKeyPressed = true;
        } else if (key == Qt.Key_VolumeUp) {
            eventAccepted = true;
            volumeUpKeyPressed = true;
        }

        /* Determine how to handle it  */
        if (volumeDownKeyPressed && volumeUpKeyPressed) {
            if (aVolumeKeyWasReleased) {
                bothVolumeKeysPressed();
            }
            aVolumeKeyWasReleased = false;
        } else if (volumeDownKeyPressed) {
            if (powerKeyPressed && aPowerKeyWasReleased) {
                screenshotPressed();
                aPowerKeyWasReleased = false;
            // Don't emit volumeDownPressed if power key is held
            } else if (aPowerKeyWasReleased){
                volumeDownPressed();
            }
        } else if (volumeUpKeyPressed) {
            volumeUpPressed();
        }

        return eventAccepted;
    }

    function onKeyReleased(key) {
        if (key == Qt.Key_PowerDown || key == Qt.Key_PowerOff) {
            powerKeyLongPressTimer.stop();
            eventAccepted = true;
            powerKeyPressed = false;
            aPowerKeyWasReleased = true;
        } else if (key == Qt.Key_VolumeDown) {
            eventAccepted = true;
            volumeDownKeyPressed = false;
            aVolumeKeyWasReleased = false;
        } else if (key == Qt.Key_VolumeUp) {
            eventAccepted = true;
            volumeUpKeyPressed = false;
            aVolumeKeyWasReleased = true;
        }

        return eventAccepted;
    }
}
