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
import Dash 0.1

Item {
    id: root

    property string source
    property alias image: innerImage
    property alias asynchronous: innerImage.asynchronous
    property alias verticalAlignment: innerImage.verticalAlignment
    property alias horizontalAlignment: innerImage.horizontalAlignment
    property alias fillMode: innerImage.fillMode

    CroppedImageSizer {
        id: sizer
        source: root.source
        width: root.width
        height: root.height
    }

    Image {
        id: innerImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: sizer.sourceSize.width == 0 && sizer.sourceSize.height == 0 ? undefined : sizer.sourceSize
        source: sizer.sourceSize.width == -1 && sizer.sourceSize.height == -1 ? "" : root.source
    }
}
