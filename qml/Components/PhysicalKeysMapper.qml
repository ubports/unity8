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

    readonly property bool altTabPressed: d.altTabPressed

    property int powerKeyLongPressCount: 31 // about 2s

    // For testing. If running windowed (e.g. tryShell), Alt+Tab is taken by the
    // running desktop, set this to true to use Ctrl+Tab instead.
    property bool controlInsteadOfAlt: false

    QtObject {
        id: d

        property bool volumeDownKeyPressed: false
        property bool volumeUpKeyPressed: false
        property bool ignoreVolumeEvents: false

        property bool altPressed: false
        property bool altTabPressed: false

        property int powerButtonCount
    }

    function onKeyPressed(event) {
        if (event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff) {
            if (event.isAutoRepeat) {
                d.powerButtonCount++;

                // We count repeats rather than watch the time because if the
                // system is loaded, we may misinterpret a long wall-clock
                // delay as a long press, when in fact we just didn't get
                // around to noticing the key-release event in time.  But if we
                // count events instead, we will be in sync with the event
                // queue.
                if (d.powerButtonCount === powerKeyLongPressCount) {
                    root.powerKeyLongPressed();
                }
            } else {
                d.powerButtonCount = 0;
            }
        } else if ((event.key == Qt.Key_MediaTogglePlayPause || event.key == Qt.Key_MediaPlay) && !event.isAutoRepeat) {
            event.accepted = callManager.handleMediaKey(false);
        } else if (event.key == Qt.Key_VolumeDown) {
            if (event.isAutoRepeat && !d.ignoreVolumeEvents) root.volumeDownTriggered();
            else if (!event.isAutoRepeat) {
                if (d.volumeUpKeyPressed) {
                    if (Powerd.status === Powerd.On) {
                        root.screenshotTriggered();
                    }
                    d.ignoreVolumeEvents = true;
                }
                d.volumeDownKeyPressed = true;
            }
        } else if (event.key == Qt.Key_VolumeUp) {
            if (event.isAutoRepeat && !d.ignoreVolumeEvents) root.volumeUpTriggered();
            else if (!event.isAutoRepeat) {
                if (d.volumeDownKeyPressed) {
                    if (Powerd.status === Powerd.On) {
                        root.screenshotTriggered();
                    }
                    d.ignoreVolumeEvents = true;
                }
                d.volumeUpKeyPressed = true;
            }
        } else if (event.key == Qt.Key_Alt || (root.controlInsteadOfAlt && event.key == Qt.Key_Control)) {
            d.altPressed = true;
        } else if (event.key == Qt.Key_Tab) {
            if (d.altPressed && !d.altTabPressed) {
                d.altTabPressed = true;
                event.accepted = true;
            }
        }
    }

    function onKeyReleased(event) {
        if (event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff) {
            event.accepted = true;
        } else if (event.key == Qt.Key_VolumeDown) {
            if (!d.ignoreVolumeEvents) root.volumeDownTriggered();
            d.volumeDownKeyPressed = false;
            if (!d.volumeUpKeyPressed) d.ignoreVolumeEvents = false;
        } else if (event.key == Qt.Key_VolumeUp) {
            if (!d.ignoreVolumeEvents) root.volumeUpTriggered();
            d.volumeUpKeyPressed = false;
            if (!d.volumeDownKeyPressed) d.ignoreVolumeEvents = false;
        } else if (event.key == Qt.Key_Alt || (root.controlInsteadOfAlt && event.key == Qt.Key_Control)) {
            d.altPressed = false;
            if (d.altTabPressed) {
                d.altTabPressed = false;
                event.accepted = true;
            }
        }
    }
}
