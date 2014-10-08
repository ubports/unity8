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

Loader {
    id: root

    property alias widgetSource: root.source
    property bool dimmed: false
    property var indicatorProperties: undefined
    property bool indicatorVisible: item ? item.enabled : false
    property string identifier

    opacity: dimmed ? 0.4 : 1
    Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.BriskDuration } }

    function updateProperties() {
        for(var pName in indicatorProperties) {
            if (item.hasOwnProperty(pName)) {
                item[pName] = indicatorProperties[pName];
            }
        }
    }

    onLoaded: updateProperties()

    onIndicatorPropertiesChanged: {
        if (status === Loader.Ready) {
            updateProperties();
        }
    }

    Binding {
        target: item
        property: "identifier"
        value: identifier
    }

    Binding {
        target: item
        property: "objectName"
        value: identifier + "-widget"
    }
}
