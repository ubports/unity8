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
import "../../Components"

Carousel {
    id: peopleCarousel
    tileAspectRatio: 1
    minimumTileWidth: units.gu(13)
    itemComponent: carouselDelegatePeople
    selectedItemScaleFactor: 1.2
    cacheBuffer: 1404 // 18px * 13gu * 6
    height: implicitHeight + units.gu(6)

    Component {
        id: carouselDelegatePeople
        CarouselDelegatePeople {
            dataModel: data

            Data {
                id: data
                uri: model.column_0
                text: model.column_5
                name: model.column_4
                avatar: model.column_1
            }
        }
    }
}
