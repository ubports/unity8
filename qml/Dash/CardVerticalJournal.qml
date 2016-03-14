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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Components"

DashRenderer {
    id: root

    readonly property double collapseLimit: units.gu(35)

    expandedHeight: Math.max(cardVerticalJournal.implicitHeight, minHeight)
    collapsedHeight: Math.max(Math.min(collapseLimit, cardVerticalJournal.implicitHeight), minHeight)
    // TODO: implement collapsedItemCount

    // This minHeight is used as bootstrapper for the height. Vertical Journal
    // is special by the fact that it doesn't know how to calculate its implicit height unless we give it
    // enough height that it can start creating its children so we make sure it has enough height for that
    // in case the model is non empty
    readonly property double minHeight: root.model.count >= 1 ? cardVerticalJournal.rowSpacing + 1 : 0

    function clearView() {
        cardVerticalJournal.model = null;
        cardVerticalJournal.model = root.model;
    }

    // Clear the view if the cardTool changes its sizes
    // means it is still settling. This is
    // necessary because the VerticalJournal does
    // not support its elements changing height so
    // we need to construct all the items with the settled
    // size of the cardTool
    Connections {
        target: cardTool
        onArtShapeSizeChanged: root.clearView();
        onHeaderHeightChanged: root.clearView();
    }

    ResponsiveVerticalJournal {
        id: cardVerticalJournal

        model: root.model

        anchors.fill: parent
        rowSpacing: minimumColumnSpacing
        columnWidth: cardTool.cardWidth

        cacheBuffer: root.cacheBuffer
        displayMarginBeginning: root.displayMarginBeginning
        displayMarginEnd: root.displayMarginEnd

        delegate: Loader {
            id: loader
            sourceComponent: cardTool.cardComponent
            width: cardTool.cardWidth
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
