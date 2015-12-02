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
import Cursor 1.0 // For MousePointer

MousePointer {
    id: mousePointer
    opacity: cursorVisible ? 1 : 0

    property bool cursorVisible: visible // initial value, based on shell.hasMouse

    Image {
        x: -mousePointer.hotspotX
        y: -mousePointer.hotspotY
        source: "image://cursor/" + mousePointer.themeName + "/" + mousePointer.cursorName
    }

    QtObject {
        id: d
        property bool touchDetected: false;
    }

    function hideCursor() {
        d.touchDetected = true;
        cursorVisible = false;
    }

    function revealCursor() {
        if (d.touchDetected) {
            d.touchDetected = false;
            cursorVisible = true;
        }
    }
}
