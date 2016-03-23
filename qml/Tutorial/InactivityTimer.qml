/*
 * Copyright (C) 2015 Canonical, Ltd.
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
    readonly property alias running: internalTimer.running
    property alias interval: internalTimer.interval
    property var page
    property int lastInputTimestamp

    function start() {
        internalTimer.start();
    }

    ////

    onLastInputTimestampChanged: {
        if (internalTimer.running) {
            internalTimer.restart();
        }
    }

    Connections {
        target: page
        onIsReadyChanged: {
            if (page.isReady && internalTimer.running) {
                internalTimer.restart();
            }
        }
    }

    Timer {
        id: internalTimer

        interval: 3000

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
