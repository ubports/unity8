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

import QtQuick 2.3

Image {
    fillMode: Image.PreserveAspectCrop
    property bool resized: false
    property bool resizing: false
    visible: resized
    onSourceSizeChanged: {
        if (!resized && !resizing) {
            resizing = true;
            var ar = width / height;
            var ssar = sourceSize.width / sourceSize.height;
            if (ar > ssar) {
                sourceSize = Qt.size(width, 0);
            } else {
                sourceSize = Qt.size(0, height);
            }
            resizing = false;
            resized = true;
        }
    }
}
