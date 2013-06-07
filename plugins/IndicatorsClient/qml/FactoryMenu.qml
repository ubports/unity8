/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0

Item {
    id: __menuFactory

    property QtObject menu
    property QtObject listView
    property QtObject actionGroup
    property variant widgetsMap
    property bool isCurrentItem
    readonly property bool empty: (__loader.source !== "" && __loader.status == Loader.Ready) ? __loader.item.state === "EMPTY" : true

    signal selectItem(int targetIndex)

    implicitHeight: (__loader.status === Loader.Ready) ? __loader.item.implicitHeight : 0
    Loader {
        id: __loader
        anchors.fill: parent
        asynchronous: true
        source: {
            if (!__menuFactory.menu ||  !__menuFactory.menu.extra || !__menuFactory.widgetsMap) {
                return ''
            }
            var widgetType = __menuFactory.menu.extra.canonical_type
            var sourceFile = null
            if (widgetType) {
                sourceFile = __menuFactory.widgetsMap.find(widgetType)
            }
            if (!sourceFile) {
                if (widgetType === "com.canonical.indicator.root") {
                   sourceFile == ""
                // Try discovery the item based on the basic properties
                } else if (menu.hasSection) {
                    sourceFile = "SectionMenu.qml"
                } else {
                    sourceFile = "Menu.qml"
                }
            }
            return sourceFile
        }
        onStatusChanged: {
            if (status == Loader.Ready) {
                item.listViewIsCurrentItem = __menuFactory.isCurrentItem
            }
        }

        // Binding all properties for the item, to make sure that any change in the
        // property will be propagated to the __loader.item at any time
        Binding {
            target: __loader.item
            property: "listViewIsCurrentItem"
            value: isCurrentItem
            when: (__loader.status == Loader.Ready)
        }

        Binding {
            target: __loader.item
            property: "actionGroup"
            value: __menuFactory.actionGroup
            when: (__loader.status == Loader.Ready)
        }

        Binding {
            target: __loader.item
            property: "menu"
            value: __menuFactory.menu
            when: (__loader.status == Loader.Ready)
        }
    }
}
