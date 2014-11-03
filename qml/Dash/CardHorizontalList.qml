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

import QtQuick 2.2
import Ubuntu.Components 1.1
import "../Components"
import "../Components/Flickables" as Flickables

DashRenderer {
    id: root

    expandedHeight: cardTool.cardHeight + units.gu(2)
    collapsedHeight: expandedHeight
    clip: true

    Flickables.ListView {
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
                item.template = Qt.binding(function() { return cardTool.template; });
                item.components = Qt.binding(function() { return cardTool.components; });
                item.titleAlignment = Qt.binding(function() { return cardTool.titleAlignment; });
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
