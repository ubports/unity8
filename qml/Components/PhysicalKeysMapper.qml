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
import Powerd 0.1

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

    property bool screenshotPressed: d.volumeUpKeyPressed && d.volumeDownKeyPressed
    property bool volumeDownPressed: d.volumeDownKeyPressed && !d.volumeUpKeyPressed
    property bool volumeUpPressed: d.volumeUpKeyPressed && !d.volumeDownKeyPressed

    QtObject {
        id: d

        property bool volumeDownKeyPressed: false
        property bool volumeUpKeyPressed: false
    }

    Timer {
        id: powerKeyLongPressTimer

        interval: 2000
        onTriggered: root.powerKeyLongPress();
    }


    function onKeyPressed(event) {
        var eventAccepted = false;

        /* Determine what key was pressed */
        if (event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff) {

            // FIXME: We only consider power key presses if the screen is
            // on because of bugs 1410830/1409003.  The theory is that when
            // those bugs are encountered, there is a >2s delay between the
            // power press event and the power release event, which causes
            // the shutdown dialog to appear on resume.  So to avoid that
            // symptom while we investigate the root cause, we simply won't
            // initiate any dialogs when the screen is off.
            // This also prevents taking screenshots when the screen is off.
            if (Powerd.status === Powerd.On) {
                if (!event.isAutoRepeat) {
                    powerKeyLongPressTimer.restart();
                }
                eventAccepted = true;
            }
        } else if (event.key == Qt.Key_MediaTogglePlayPause || event.key == Qt.Key_MediaPlay) {
            eventAccepted = callManager.handleMediaKey(false);
        } else if (event.key == Qt.Key_VolumeDown) {
            d.volumeDownKeyPressed = true;
        } else if (event.key == Qt.Key_VolumeUp) {
            d.volumeUpKeyPressed = true;
        }

        return eventAccepted;
    }

    function onKeyReleased(event) {
        var eventAccepted = false;

        if (event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff) {
            powerKeyLongPressTimer.stop();
            eventAccepted = true;
        } else if (event.key == Qt.Key_VolumeDown) {
            d.volumeDownKeyPressed = false;
        } else if (event.key == Qt.Key_VolumeUp) {
            d.volumeUpKeyPressed = false;
        }

        return eventAccepted;
    }
}
