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
import Unity.Indicators 0.1 as Indicators
import "../Components"

Item {
    id: indicatorItem

    property alias widgetSource: loader.source
    property bool highlighted: false
    property bool dimmed: false
    property var indicatorProperties: undefined
    property bool indicatorVisible: loader.item ? loader.item.enabled : false

    opacity: dimmed ? 0.4 : 1
    Behavior on opacity { StandardAnimation {} }

    width: loader.item ? loader.item.width : 0

    Loader {
        id: loader

        onLoaded: {
            item.height = Qt.binding(function() { return indicatorItem.height; });

            for(var pName in indicatorProperties) {
                if (item.hasOwnProperty(pName)) {
                    item[pName] = indicatorProperties[pName];
                }
            }
        }
    }
}
