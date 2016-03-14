/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Unity.Indicators 0.1 as Indicators
import Utils 0.1
import "../Components"
import "Indicators"

Rectangle {
    id: content

    property QtObject indicatorsModel: null
    property int currentMenuIndex: -1
    color: theme.palette.normal.background

    width: units.gu(40)
    height: units.gu(42)

    onCurrentMenuIndexChanged: {
        listViewContent.currentIndex = currentMenuIndex;
    }

    ListView {
        id: listViewContent
        objectName: "indicatorsContentListView"
        anchors.fill: parent
        model: content.indicatorsModel

        highlightFollowsCurrentItem: true
        interactive: false
        highlightMoveDuration: 0
        orientation: ListView.Horizontal
        // Load all the indicator menus (a big number)
        cacheBuffer: 1073741823

        // for additions/removals.
        onCountChanged: {
            listViewContent.currentIndex = content.currentMenuIndex;
        }

        delegate: Loader {
            id: loader

            width: ListView.view.width
            height: ListView.view.height
            objectName: identifier
            asynchronous: true
            visible: ListView.isCurrentItem

            sourceComponent: IndicatorPage {
                objectName: identifier + "-page"

                identifier: model.identifier
                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath
            }

            onVisibleChanged: {
                // Reset the indicator states
                if (!visible && status == Loader.Ready) {
                    item.reset();
                }
            }
        }
    }
}
