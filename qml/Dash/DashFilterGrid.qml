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
import "../Components"
import ".."

DashRenderer {
    id: dashFilterGrid

    property alias cellWidth: filterGrid.cellWidth
    property alias cellHeight: filterGrid.cellHeight
    property alias delegate: filterGrid.delegate
    property alias delegateWidth: filterGrid.delegateWidth
    property alias delegateHeight: filterGrid.delegateHeight
    property alias verticalSpacing: filterGrid.verticalSpacing
    property alias maximumNumberOfColumns: filterGrid.maximumNumberOfColumns
    property alias minimumHorizontalSpacing: filterGrid.minimumHorizontalSpacing
    property alias collapsedRowCount: filterGrid.collapsedRowCount

    property FilterGrid grid: filterGrid

    collapsedHeight: filterGrid.collapsedHeight
    columns: filterGrid.columns
    rows: filter ? filterGrid.collapsedRowCount : filterGrid.uncollapsedRowCount
    currentItem: filterGrid.currentItem
    expandable: filterGrid.expandable
    height: filterGrid.height
    margins: filterGrid.margins
    uncollapsedHeight: filterGrid.uncollapsedHeight

    function startFilterAnimation(filter) {
        filterGrid.startFilterAnimation(filter)
    }

    FilterGrid {
        id: filterGrid
        width: dashFilterGrid.width
        minimumHorizontalSpacing: units.gu(0.5)
        delegateWidth: units.gu(11)
        delegateHeight: units.gu(9.5)
        verticalSpacing: units.gu(2)
        model: dashFilterGrid.model
        filter: dashFilterGrid.filter
        highlightIndex: dashFilterGrid.highlightIndex
        delegateCreationBegin: dashFilterGrid.delegateCreationBegin
        delegateCreationEnd: dashFilterGrid.delegateCreationEnd

        onFilterChanged: {
            dashFilterGrid.filter = filter
            filter = Qt.binding(function() { return dashFilterGrid.filter })
        }
    }
}
