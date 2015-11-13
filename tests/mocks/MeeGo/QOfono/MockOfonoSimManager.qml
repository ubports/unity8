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

import QtQuick 2.4
import MeeGo.QOfono 0.2

Item {
    id: simManager

    property string modemPath
    readonly property alias present: d.present
    readonly property alias ready: d.ready
    readonly property var preferredLanguages: ["de", "fr", "it", "en"]

    QtObject {
        id: d

        property bool present: false
        property bool ready: false

        function updatePresence() {
            d.present = MockQOfono.isModemPresent(simManager.modemPath)
            d.ready = MockQOfono.isModemReady(simManager.modemPath);
        }
    }

    // Simulate QOfono's asynchronous initialization
    Timer {
        id: asyncTimer
        interval: 1
        onTriggered: d.updatePresence()
    }

    onModemPathChanged: asyncTimer.start()

    Connections {
        target: MockQOfono
        onModemsChanged: asyncTimer.start()
    }
}
