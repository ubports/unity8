/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import Ubuntu.Components 1.3

Item {
    id: root
    property url source

    CrossFadeImage {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        // Limit how much memory we reserve and avoid reloading when item size
        // changes or is rotated by specifying sourceSize.
        //
        // FIXME: If the source image has a portrait aspect ratio, we should swap
        // sourceSize.width and sourceSize.height to prevent blurriness from double
        // scaling.  We could easily do that with a tiny image loader to check
        // the aspect ratio first, but when we change sourceSize, we lose all
        // the benefits of CrossFadeImage.  So we need to fix that component
        // first to gracefully handle sourceSize changes (LP: #1599203).
        readonly property int maxSize: Math.max(Screen.width, Screen.height)
        sourceSize.width: 0
        sourceSize.height: maxSize

        source: root.source
    }
}
