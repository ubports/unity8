/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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
import QtQuick.Window 2.2
import Ubuntu.Thumbnailer 0.1

Image {
    source: "image://thumbnailer/" + Qt.resolvedUrl("graphics/paper.png")
    fillMode: Image.PreserveAspectCrop
    horizontalAlignment: Image.AlignRight
    verticalAlignment: Image.AlignTop
    // avoid CPU scaling when window size changes
    readonly property int maxSize: Math.max(Screen.width, Screen.height)
    sourceSize.width: maxSize
    sourceSize.height: 0
}
