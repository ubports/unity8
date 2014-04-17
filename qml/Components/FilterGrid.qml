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
import Utils 0.1
import "../Components"

/*
    A ResponsiveGridView that can optionally have the number of rows being displayed
    reduced to collapsedRowCount, in which case a button saying "View all (123)"
    will be shown at the bottom. If clicked, FilterGrid will them expand vertically
    to display all rows.
 */
Item {
    id: root

    /* If true, the number of elements displayed will be limited by collapsedRowCount.
       If false, all elements will be displayed, effectively looking the same as a regular
       ResponsiveGridView. */
    property bool filter: true

    /* Whether, when collapsed, a button should be displayed enabling the user to expand
       the grid to its full size. */
    readonly property bool expandable: model.count > rowsWhenCollapsed * iconTileGrid.columns

    property var model: null

    /* Maximum number of rows to be show when filter=true. */
    property int collapsedRowCount: 2
    property int uncollapsedRowCount: Math.ceil(model.count / columns)
    /* Never show more rows than model would fill up. */
    readonly property int rowsWhenCollapsed: Math.min(collapsedRowCount, uncollapsedRowCount)
    readonly property int collapsedHeight: iconTileGrid.contentHeightForRows(rowsWhenCollapsed)
    readonly property int uncollapsedHeight: iconTileGrid.contentHeightForRows(uncollapsedRowCount)

    property alias minimumHorizontalSpacing: iconTileGrid.minimumHorizontalSpacing
    property alias maximumNumberOfColumns: iconTileGrid.maximumNumberOfColumns
    property alias columns: iconTileGrid.columns
    property alias delegateWidth: iconTileGrid.delegateWidth
    property alias delegateHeight: iconTileGrid.delegateHeight
    property alias verticalSpacing: iconTileGrid.verticalSpacing
    readonly property alias margins: iconTileGrid.margins
    property alias delegate: iconTileGrid.delegate
    property alias cellWidth: iconTileGrid.cellWidth
    property alias cellHeight: iconTileGrid.cellHeight
    property alias delegateCreationBegin: iconTileGrid.delegateCreationBegin
    property alias delegateCreationEnd: iconTileGrid.delegateCreationEnd
    readonly property alias originY: iconTileGrid.originY
    readonly property alias flicking: iconTileGrid.flicking
    readonly property alias moving: iconTileGrid.moving
    readonly property alias pressDelay: iconTileGrid.pressDelay
    property alias highlightIndex: iconTileGrid.highlightIndex
    readonly property alias currentItem: iconTileGrid.currentItem

    height: !filterAnimation.running ? childrenRect.height : height
    clip: filterAnimation.running

    NumberAnimation {
        property bool filterEndValue
        id: filterAnimation
        target: root
        property: "height"
        to: filterEndValue ? root.collapsedHeight : root.uncollapsedHeight
        // Duration and easing here match the ListViewWithPageHeader::m_contentYAnimation
        // otherwise since both animations can run at the same time you'll get
        // some visual weirdness.
        duration: 200
        easing.type: Easing.InOutQuad
        onStopped: {
            root.filter = filterEndValue;
        }
    }

    function startFilterAnimation(filter) {
        filterAnimation.filterEndValue = filter
        filterAnimation.start();
    }

    ResponsiveGridView {
        id: iconTileGrid

        anchors { left: parent.left; right: parent.right }
        height: totalContentHeight
        interactive: false

        minimumHorizontalSpacing: units.gu(0.5)
        maximumNumberOfColumns: 6
        delegateWidth: units.gu(11)
        delegateHeight: units.gu(9.5)
        verticalSpacing: units.gu(2)

        model: LimitProxyModel {
            model: root.model
            limit: (filter && !filterAnimation.running) ? rowsWhenCollapsed * iconTileGrid.columns : -1
        }
    }
}
