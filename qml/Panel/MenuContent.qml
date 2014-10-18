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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Unity.Indicators 0.1 as Indicators
import Utils 0.1
import "../Components"
import "../Components/Flickables" as Flickables
import "Indicators"

Rectangle {
    id: content

    property QtObject indicatorsModel: null
    readonly property alias currentMenuIndex: listViewHeader.currentIndex
    color: "#221e1c" // FIXME not in palette yet
    property real headerHeight: listViewHeader.height

    width: units.gu(40)
    height: units.gu(42)

    function setCurrentMenuIndex(index, animate) {
        // FIXME - https://bugreports.qt-project.org/browse/QTBUG-41229
        listViewHeader.currentIndex = -1;
        listViewHeader.currentIndex = index;
    }

    Flickables.ListView {
        id: listViewHeader
        objectName: "indicatorsHeaderListView"
        model: content.indicatorsModel
        clip: true

        anchors {
            left: parent.left
            right: parent.right
        }
        height: units.gu(8.5)

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        boundsBehavior: Flickable.StopAtBounds
        // Load all the indicator menus (a big number)
        cacheBuffer: 1073741823

        delegate: Header {
            width: ListView.view.width
            height: implicitHeight

            title: indicatorDelegate.title !== "" ? indicatorDelegate.title : identifier

            IndicatorDelegate {
                id: indicatorDelegate
                Component.onCompleted: {
                    for(var pName in indicatorProperties) {
                        if (indicatorDelegate.hasOwnProperty(pName)) {
                            indicatorDelegate[pName] = indicatorProperties[pName];
                        }
                    }
                }
            }
        }
    }

    Flickables.ListView {
        id: listViewContent
        objectName: "indicatorsContentListView"
        anchors {
            left: parent.left
            right: parent.right
            top: listViewHeader.bottom
            bottom: parent.bottom
        }
        model: content.indicatorsModel
        clip: true

        currentIndex: listViewHeader.currentIndex
        interactive: false
        highlightMoveDuration: 0
        orientation: ListView.Horizontal
        // Load all the indicator menus (a big number)
        cacheBuffer: 1073741823

        delegate: Loader {
            id: loader
            width: ListView.view.width
            height: ListView.view.height
            objectName: identifier

            source: pageSource
            asynchronous: true

            onVisibleChanged: {
                // Reset the indicator states
                if (!visible && item && item["reset"]) {
                    item.reset()
                }
            }

            onLoaded: {
                for(var pName in indicatorProperties) {
                    if (item.hasOwnProperty(pName)) {
                        item[pName] = indicatorProperties[pName]
                    }
                }
            }

            Binding {
                target: loader.item
                property: "identifier"
                value: identifier
            }

            Binding {
                target: loader.item
                property: "objectName"
                value: identifier + "-page"
            }
        }
    }
}
