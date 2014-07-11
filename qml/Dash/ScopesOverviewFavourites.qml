/*
 * Copyright (C) 2014 Canonical, Ltd.
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

ListView {
    id: root

    signal clicked(int index, var result)
    signal pressAndHold(int index)

    property var cardTool: null
    property real scopeHeight: 0
    property real scopeWidth: 0
    property real appliedScale: 1

    orientation: ListView.Horizontal
    // TODO current item

    spacing: units.gu(2) / appliedScale

    delegate: Loader {
        id: loader


        sourceComponent: cardTool.cardComponent
        onLoaded: {
            item.fixedHeaderHeight = Qt.binding(function() { return cardTool.headerHeight / appliedScale; });
            item.fontScale = Qt.binding(function() { return 1 / appliedScale; });
            item.height = Qt.binding(function() { return root.scopeHeight; });
            item.width = Qt.binding(function() { return root.scopeWidth; });
            item.cardData = Qt.binding(function() { return model; });
            item.template = Qt.binding(function() { return cardTool.template; });
            item.components = Qt.binding(function() { return cardTool.components; });
            item.headerAlignment = Qt.binding(function() { return cardTool.headerAlignment; });
        }

        Connections {
            target: loader.item
            onClicked: root.clicked(index, result)
        }
    }
}
