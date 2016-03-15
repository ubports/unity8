/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Unity.Application 0.1

// This component will change the state of the surface based on the surface
// state and shell chrome.
//
// Chrome changed to LowChrome -> server sets client window state to "fullscreen"
// Chrome changed to NormalChrome -> server sets client window to "restored" state.
// Chrome set and state change to restored -> server RESETS client window state to "fullscreen"
// Chrome not set and state change to restored -> client window stays "restored"
// Chrome not set and state change to fulscreen -> client window stays "fullscreen"
QtObject {
    property bool active: true
    property QtObject application: null

    readonly property var lastSurface: application && application.session ?
                              application.session.lastSurface : null
    onLastSurfaceChanged: {
        if (!active || !lastSurface) return;
        if (lastSurface.shellChrome === Mir.LowChrome) {
            lastSurface.state = Mir.FullscreenState;
        }
    }

    property var _connections: Connections {
        target: lastSurface
        onShellChromeChanged: {
            if (!active || !lastSurface) return;
            if (lastSurface.shellChrome === Mir.LowChrome) {
                lastSurface.state = Mir.FullscreenState;
            } else {
                lastSurface.state = Mir.RestoredState;
            }
        }
        onStateChanged: {
            if (!active) return;
            if (lastSurface.state === Mir.RestoredState && lastSurface.shellChrome === Mir.LowChrome) {
                lastSurface.state = Mir.FullscreenState;
            }
        }
    }
}
