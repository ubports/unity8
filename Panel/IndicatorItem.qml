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
import IndicatorsClient 0.1 as IndicatorsClient

Item {
    id: indicatorItem

    property alias iconUrl: loader.source
    property bool highlighted: false
    property bool dimmed: false
    property var initialProperties: undefined

    opacity: dimmed ? 0.4 : 1

    // only visible when non-empty
    visible: loader.item != undefined && loader.status == Loader.Ready
    width: visible ? loader.item.width : 0

    Loader {
        id: loader

        onStatusChanged: {
            if (status == Loader.Ready) {
                item.height = Qt.binding(function() { return indicatorItem.height; })

                for(var pName in initialProperties) {
                    if (item.hasOwnProperty(pName)) {
                        item[pName] = initialProperties[pName]
                    }
                }
            }
        }
    }

    Connections {
        target: loader.item
        onVisibleChanged: { visible = loader.item.visible }
    }

    Rectangle {
        color: "#dd4814"
        height: units.dp(2)
        width: parent.width
        anchors.top: parent.bottom
        visible: highlighted
    }
}
