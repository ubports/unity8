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

import QtQuick 2.12
import Cursor 1.1
import Powerd 0.1

MousePointer {
    id: mousePointer

    CursorImageInfo {
        id: imageInfo
        themeName: mousePointer.themeName
        cursorName: mousePointer.cursorName
        cursorHeight: mousePointer.height
    }

    Loader {
        active: mousePointer.visible && imageInfo.frameCount > 1
        sourceComponent: AnimatedSprite {
            x: -imageInfo.hotspot.x
            y: -imageInfo.hotspot.y
            source: imageInfo.imageSource

            interpolate: false

            width: imageInfo.frameWidth
            height: imageInfo.frameHeight

            frameCount: imageInfo.frameCount
            frameDuration: imageInfo.frameDuration
            frameWidth: imageInfo.frameWidth
            frameHeight: imageInfo.frameHeight

            running: Powerd.status === Powerd.On
        }
    }

    Loader {
        active: mousePointer.visible && imageInfo.frameCount === 1
        sourceComponent: Image {
            x: -imageInfo.hotspot.x
            y: -imageInfo.hotspot.y
            source: imageInfo.imageSource
            width: sourceSize.width
            height: sourceSize.height
        }
    }
}
