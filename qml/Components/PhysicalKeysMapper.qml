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
import Powerd 0.1

/*!
 \brief A mapper for the physical keys on the device

 A mapper to handle events triggered by pressing physical keys on a device.
 Keys included are
    * Volume Decrease
    * Volume Increase
    * Power

 This allows for handling the following events
    * Power dialog
    * Volume Decreases/Increases
    * Screenshots

*/

Item {
    id: root

    signal powerKeyLongPressed;
    signal volumeDownTriggered;
    signal volumeUpTriggered;
    signal screenshotTriggered;

    QtObject {
        id: d

        property bool volumeDownKeyPressed: false
        property bool volumeUpKeyPressed: false
        property bool ignoreVolumeEvents: false
    }

    Timer {
        id: powerKeyLongPressTimer

        interval: 2000
        onTriggered: root.powerKeyLongPressed();
    }


    function onKeyPressed(event) {
        if ((event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff)
            && !event.isAutoRepeat) {

            // FIXME: We only consider power key presses if the screen is
            // on because of bugs 1410830/1409003.  The theory is that when
            // those bugs are encountered, there is a >2s delay between the
            // power press event and the power release event, which causes
            // the shutdown dialog to appear on resume.  So to avoid that
            // symptom while we investigate the root cause, we simply won't
            // initiate any dialogs when the screen is off.
            if (Powerd.status === Powerd.On) {
                powerKeyLongPressTimer.restart();
            }
            event.accepted = true;
        } else if ((event.key == Qt.Key_MediaTogglePlayPause || event.key == Qt.Key_MediaPlay)
                   && !event.isAutoRepeat) {
            event.accepted = callManager.handleMediaKey(false);
        } else if (event.key == Qt.Key_VolumeDown) {
            if (event.isAutoRepeat && !d.ignoreVolumeEvents) root.volumeDownTriggered();
            else if (!event.isAutoRepeat) {
                if (d.volumeUpKeyPressed) {
                    if (Powerd.status === Powerd.On) root.screenshotTriggered();
                    d.ignoreVolumeEvents = true;
                }
                d.volumeDownKeyPressed = true;
            }
        } else if (event.key == Qt.Key_VolumeUp) {
            if (event.isAutoRepeat && !d.ignoreVolumeEvents) root.volumeUpTriggered();
            else if (!event.isAutoRepeat) {
                if (d.volumeDownKeyPressed) {
                    if (Powerd.status === Powerd.On) root.screenshotTriggered();
                    d.ignoreVolumeEvents = true;
                }
                d.volumeUpKeyPressed = true;
            }
        }
    }

    function onKeyReleased(event) {
        if (event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff) {
            powerKeyLongPressTimer.stop();
            event.accepted = true;
        } else if (event.key == Qt.Key_VolumeDown) {
            if (!d.ignoreVolumeEvents) root.volumeDownTriggered();
            d.volumeDownKeyPressed = false;
            if (!d.volumeUpKeyPressed) d.ignoreVolumeEvents = false;
        } else if (event.key == Qt.Key_VolumeUp) {
            if (!d.ignoreVolumeEvents) root.volumeUpTriggered();
            d.volumeUpKeyPressed = false;
            if (!d.volumeDownKeyPressed) d.ignoreVolumeEvents = false;
        }
    }
}
