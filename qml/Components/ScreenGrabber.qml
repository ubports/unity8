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
import ScreenGrabber 0.1

Rectangle {
    id: root
    enabled: false
    visible: false
    color: "white"
    anchors.fill: parent
    opacity: 0.0

    QtObject {
        id: keyState
        property bool volumeUp: false
        property bool volumeDown: false
        property bool ignoreKeyPresses: false
    }

    ScreenGrabber {
        id: screenGrabber
        objectName: "screenGrabber"
    }

    function enable(flag)
    {
        keyState.ignoreKeyPresses = !flag;
    }

    function onKeyPressed(key) {
        if (keyState.ignoreKeyPresses)
            return;

        if (key == Qt.Key_VolumeUp)
            keyState.volumeUp = true;
        else if (key == Qt.Key_VolumeDown)
            keyState.volumeDown = true;

        if (keyState.volumeDown && keyState.volumeUp) {
            enabled = true;
            visible = true;
            fadeIn.start();
        }
    }

    function onKeyReleased(key) {
        if (key == Qt.Key_VolumeUp)
            keyState.volumeUp = false;
        else if (key == Qt.Key_VolumeDown)
            keyState.volumeDown = false;
    }

    NumberAnimation on opacity {
        id: fadeIn
        from: 0.0
        to: 1.0
        onStopped: {
            if (enabled && visible) {
                fadeOut.start()
            }
        }
    }

    NumberAnimation on opacity {
        id: fadeOut
        from: 1.0
        to: 0.0
        onStopped: {
            if (enabled && visible) {
                screenGrabber.captureAndSave();
                enabled = false
                visible = false
            }
        }
    }
}
