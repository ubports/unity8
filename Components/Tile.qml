/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1

AbstractButton {
    property url source
    property int fillMode: Image.PreserveAspectCrop
    property int horizontalAlignment: Image.AlignHCenter
    property int verticalAlignment: Image.AlignVCenter
    property string text
    property int imageWidth
    property int imageHeight
    opacity: GridView.view.highlightIndex === -1 ? 1 :
                GridView.view.highlightIndex === index ? 0.6 : 0.2
    readonly property int center: (index % GridView.view.columns * width) + (width / 2)
    property int maximumLineCount: 1

    style: TileStyle {}
}
