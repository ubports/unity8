/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import "../Components"

DashRenderer {
    id: root

    expandedHeight: cardTool.cardHeight + units.gu(2)
    collapsedHeight: expandedHeight
    growsVertically: false
    innerWidth: Math.max(0, listView.width)
    clip: true

    ListView {
        id: listView
        anchors {
            fill: parent
            margins: units.gu(1)
            rightMargin: 0
        }
        rightMargin: units.gu(1)
        spacing: units.gu(1)
        model: root.model
        orientation: ListView.Horizontal
        cacheBuffer: root.cacheBuffer
        displayMarginBeginning: root.displayMarginBeginning
        displayMarginEnd: root.displayMarginEnd

        delegate: Loader {
            id: loader
            sourceComponent: cardTool.cardComponent
            anchors { top: parent.top; bottom: parent.bottom }
            width: cardTool.cardWidth
            asynchronous: true
            onLoaded: {
                item.objectName = "delegate" + index;
                item.fixedArtShapeSize = Qt.binding(function() { return cardTool.artShapeSize; });
                item.fixedHeaderHeight = Qt.binding(function() { return cardTool.headerHeight; });
                item.cardData = Qt.binding(function() { return model; });
                item.scopeStyle = root.scopeStyle;
            }
            Connections {
                target: loader.item
                onClicked: root.clicked(index, result, loader.item, model)
                onPressAndHold: root.pressAndHold(index, result, model)
            }
        }
    }
}
