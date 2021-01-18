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

import QtQuick 2.4
import Powerd 0.1
import Utils 0.1

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
    signal mediaKey;

    readonly property bool altTabPressed: d.altTabPressed
    readonly property bool superPressed: d.superPressed
    readonly property bool superTabPressed: d.superTabPressed

    property int powerKeyLongPressTime: 2000

    // For testing. If running windowed (e.g. tryShell), Alt+Tab is taken by the
    // running desktop, set this to true to use Ctrl+Tab instead.
    property bool controlInsteadOfAlt: false
    property bool controlInsteadOfSuper: false

    QtObject {
        id: d

        property bool volumeDownKeyPressed: false
        property bool volumeUpKeyPressed: false
        property bool ignoreVolumeEvents: false

        property bool altPressed: false
        property bool altTabPressed: false

        property bool superPressed: false
        property bool superTabPressed: false

        property var powerButtonPressStart: 0
    }

    InputEventGenerator {
        id: inputEventGenerator
    }

    function onKeyPressed(event, currentEventTimestamp) {
        if (event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff) {
            if (event.isAutoRepeat) {
                if (d.powerButtonPressStart > 0
                        && currentEventTimestamp - d.powerButtonPressStart >= powerKeyLongPressTime) {
                    d.powerButtonPressStart = 0;
                    root.powerKeyLongPressed();
                }
            } else {
                d.powerButtonPressStart = currentEventTimestamp;
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

        // Adding MetaModifier here because that's what keyboards do. Pressing Super_L actually gives
        // Super_L + MetaModifier. This helps to make sure we only invoke superPressed if no other
        // Modifier is pressed too.
        } else if (((event.key == Qt.Key_Super_L || event.key == Qt.Key_Super_R) && event.modifiers === Qt.MetaModifier)
                    || (root.controlInsteadOfSuper && event.key == Qt.Key_Control)
                    ) {
            d.superPressed = true;
        } else if (event.key == Qt.Key_Tab) {
            if (d.altPressed && !d.altTabPressed) {
                inputEventGenerator.generateKeyEvent(Qt.Key_Alt, false, Qt.NoModifier, currentEventTimestamp, 56);
                d.altTabPressed = true;
                event.accepted = true;
            }
            if (d.superPressed && !d.superTabPressed) {
                d.superTabPressed = true;
                event.accepted = true;
            }
        }
    }

    function onKeyReleased(event, currentEventTimestamp) {
        if (event.key == Qt.Key_PowerDown || event.key == Qt.Key_PowerOff) {
            d.powerButtonPressStart = 0;
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
            if (d.altTabPressed) {
                d.altTabPressed = false;
                event.accepted = true;
            }
            d.altPressed = false;
        } else if (event.key == Qt.Key_Tab) {
            if (d.altTabPressed) {
                event.accepted = true;
            }
        } else if (event.key == Qt.Key_Super_L || event.key == Qt.Key_Super_R || (root.controlInsteadOfSuper && event.key == Qt.Key_Control)) {
            d.superPressed = false;
            if (d.superTabPressed) {
                d.superTabPressed = false;
                event.accepted = true;
            }
        } else if (   event.key == Qt.Key_MediaNext 
                   || event.key == Qt.Key_MediaPrevious 
                   || event.key == Qt.Key_MediaPlay
                   || event.key == Qt.Key_WebCam
) {
            root.mediaKey(event.key);
        }
    }
}
