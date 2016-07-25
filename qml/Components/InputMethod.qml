/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1

Item {
    id: root

    readonly property rect visibleRect: surfaceItem.surface ? surfaceItem.surface.inputBounds : Qt.rect(0, 0, 0, 0)

    MirSurfaceItem {
        id: surfaceItem
        anchors.fill: parent

        consumesInput: true

        surfaceWidth: root.enabled ? width : -1
        surfaceHeight: root.enabled ? height : -1
        surface: SurfaceManager.inputMethodSurface

        onLiveChanged: {
            if (surface !== null && !live) {
                surface = null;
            }
        }
    }

    TouchGate {
        x: root.visibleRect.x
        y: root.visibleRect.y
        width: root.visibleRect.width
        height: root.visibleRect.height

        targetItem: surfaceItem
    }

    visible: surfaceItem.surface &&
              surfaceItem.surfaceState != Mir.HiddenState &&
              surfaceItem.surfaceState != Mir.MinimizedState &&
              root.enabled
}
