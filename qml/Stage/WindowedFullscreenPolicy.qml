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

import QtQml 2.2
import Unity.Application 0.1

// This component will change the state of the surface when the stage is loaded.
//
// On first surface load; if the surface is set to low chrome & fullscreen, the
// state of the window is returned to restored.
QtObject {
    property bool active: true
    property QtObject surface: null

    property bool _firstTimeSurface: true

    onSurfaceChanged: {
        if (!active || !surface) return;
        if (!_firstTimeSurface) return;
        _firstTimeSurface = false;

        if (surface.state === Mir.FullscreenState && surface.shellChrome === Mir.LowChrome) {
            surface.state = Mir.RestoredState;
        }
    }
}
