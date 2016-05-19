/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import Ubuntu.Components 1.3

Item {
    id: root

    readonly property bool running: delayTimer.running || inactivityTimer.running
    property int interval: 3000
    property var page
    property int lastInputTimestamp

    function start() {
        if (!delayTimer.running && !inactivityTimer.running) {
            delayTimer.start();
        }
    }

    ////

    onLastInputTimestampChanged: {
        if (inactivityTimer.running) {
            inactivityTimer.restart();
        }
    }

    Connections {
        target: page
        onIsReadyChanged: {
            if (page.isReady && inactivityTimer.running) {
                inactivityTimer.restart();
            }
        }
        onPausedChanged: {
            if (root.paused) {
                delayTimer.stop();
                inactivityTimer.stop();
            }
        }
    }

    Timer {
        id: delayTimer
        interval: Math.max(root.interval - 3000, 0)
        onTriggered: inactivityTimer.start()
    }

    Timer {
        id: inactivityTimer

        interval: Math.min(root.interval, 3000)

        onTriggered: {
            if (page.isReady) {
                if (!page.shown) {
                    page.show();
                }
            } else if (!page.skipped) {
                restart();
            }
        }
    }
}
