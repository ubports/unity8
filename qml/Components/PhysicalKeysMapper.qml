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
 \brief A mapper for the physical keys on the device

 A mapper to handle events triggered by pressing physical keys on a device.
 Keys included are
    * Volume Decrease
    * Volume Increase
    * Power

 This allows for handling the following events
    * Volume Decreases/Increases
    * Screenshots

*/

Item {
    id: root

    signal powerKeyLongPress();
    signal screenshotPressed();
    signal volumeDownPressed();
    signal volumeUpPressed();

    QtObject {
        id: d

        property bool aPowerKeyWasReleased: true
        property bool powerKeyPressed: false

        property bool volumeDownKeyPressed: false
        property bool volumeUpKeyPressed: false
    }

    // FIXME: event.isAutoRepeat is always false on Nexus 4.
    // So we use powerKeyTimer.running to avoid the PowerOff key repeat
    // https://launchpad.net/bugs/1349416
    Timer {
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
            d.powerKeyPressed = true;
        } else if (key == Qt.Key_VolumeDown) {
            d.volumeDownKeyPressed = true;
        } else if (key == Qt.Key_VolumeUp) {
            d.volumeUpKeyPressed = true;
        }

        /* Determine how to handle it  */
        if (d.volumeDownKeyPressed) {
            if (d.powerKeyPressed && d.aPowerKeyWasReleased) {
                screenshotPressed();
                d.aPowerKeyWasReleased = false;
            // Don't emit volumeDownPressed if power key is held
            } else if (d.aPowerKeyWasReleased){
                volumeDownPressed();
            }
        } else if (d.volumeUpKeyPressed) {
            volumeUpPressed();
        }
    }

    function onKeyReleased(key) {
        if (key == Qt.Key_PowerDown || key == Qt.Key_PowerOff) {
            powerKeyLongPressTimer.stop();
            d.powerKeyPressed = false;
            d.aPowerKeyWasReleased = true;
        } else if (key == Qt.Key_VolumeDown) {
            d.volumeDownKeyPressed = false;
        } else if (key == Qt.Key_VolumeUp) {
            d.volumeUpKeyPressed = false;
        }
    }
}
