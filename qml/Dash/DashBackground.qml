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

Image {
    source: anchors.fill.width > anchors.fill.height ? "graphics/paper_landscape.png" : "graphics/paper_portrait.png"
    fillMode: Image.PreserveAspectCrop
    horizontalAlignment: Image.AlignRight
    verticalAlignment: Image.AlignTop
    sourceSize.width: anchors.fill.width
    sourceSize.height: 0
}
