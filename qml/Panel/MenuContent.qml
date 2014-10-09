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

import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Unity.Indicators 0.1 as Indicators
import Utils 0.1
import "../Components"

Rectangle {
    id: content

    property QtObject indicatorsModel: null
    readonly property alias currentMenuIndex: listViewContent.currentIndex
    color: "#221e1c" // FIXME not in palette yet

    width: units.gu(40)
    height: units.gu(42)

    function setCurrentMenuIndex(index) {
        // FIXME - https://bugreports.qt-project.org/browse/QTBUG-41229
        listViewContent.currentIndex = -1;
        listViewContent.currentIndex = index;
    }

    ListView {
        id: listViewContent
        objectName: "indicatorsContentListView"
        anchors.fill: parent
        model: content.indicatorsModel
        clip: true

        highlightFollowsCurrentItem: true
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
            asynchronous: true

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
