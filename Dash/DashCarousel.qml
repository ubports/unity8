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
import "../Components"

DashRenderer {
    id: dashCarousel

    property alias cacheBuffer: carousel.cacheBuffer
    property alias itemComponent: carousel.itemComponent
    property alias minimumTileWidth: carousel.minimumTileWidth
    property alias selectedItemScaleFactor: carousel.selectedItemScaleFactor
    property alias tileAspectRatio: carousel.tileAspectRatio

    collapsedHeight: carousel.height
    currentItem: carousel.currentItem
    highlightIndex: carousel.highlightIndex
    height: carousel.implicitHeight + units.gu(6)
    uncollapsedHeight: carousel.height

    Carousel {
        id: carousel
        anchors.fill: parent
        tileAspectRatio: 198 / 288
        minimumTileWidth: units.gu(13)
        selectedItemScaleFactor: 1.14
        cacheBuffer: 1404 // 18px * 13gu * 6
        model: dashCarousel.model

        onClicked: dashCarousel.clicked(index, model, itemY)
        onPressAndHold: dashCarousel.pressAndHold(index, model, itemY)
    }
}
