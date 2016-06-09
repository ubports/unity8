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
import Cursor 1.1

MousePointer {
    id: mousePointer

    CursorImageInfo {
        id: imageInfo
        themeName: mousePointer.themeName
        cursorName: mousePointer.cursorName
    }

    AnimatedSprite {
        x: -imageInfo.hotspot.x
        y: -imageInfo.hotspot.y
        source: "image://cursor/" + mousePointer.themeName + "/" + mousePointer.cursorName

        interpolate: false

        width: imageInfo.frameWidth
        height: imageInfo.frameHeight

        frameCount: imageInfo.frameCount
        frameDuration: imageInfo.frameDuration
        frameWidth: imageInfo.frameWidth
        frameHeight: imageInfo.frameHeight
    }
}
