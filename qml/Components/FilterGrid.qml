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
    readonly property alias filtered: d.filter

    height: d.collapsed ? root.collapsedHeight : root.uncollapsedHeight
    clip: filterAnimation.running

    Behavior on height {
        id: heightBehaviour
        enabled: false
        NumberAnimation {
            id: filterAnimation
            // Duration and easing here match the ListViewWithPageHeader::m_contentYAnimation
            // otherwise since both animations can run at the same time you'll get
            // some visual weirdness.
            duration: 200
            easing.type: Easing.InOutQuad
            onRunningChanged: {
                if (!running) {
                    d.filter = d.collapsed;
                }
                heightBehaviour.enabled = false;
            }
        }
    }

    QtObject {
        id: d
        // We do have filter and collapsed properties because we need to decouple
        // the real filtering with the animation since the closing animation
        // i.e. setFilter(false. true) we still need to not be filtering until
        // the animation finishes otherwise we hide the items when the animation
        // is still running
        property bool filter: true
        property bool collapsed: true
    }

    function setFilter(filter, animate) {
        heightBehaviour.enabled = animate;
        d.collapsed = filter;
        if (!animate || !filter) {
            d.filter = filter;
        }
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
            id: limitModel
            model: root.model
            limit: d.filter ? rowsWhenCollapsed * iconTileGrid.columns : -1
        }
    }
}
