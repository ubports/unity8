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
    property bool expandable: true

    property var model: null

    /* Maximum number of rows to be show when filter=true. */
    property int collapsedRowCount: 2

    property alias minimumHorizontalSpacing: iconTileGrid.minimumHorizontalSpacing
    property alias maximumNumberOfColumns: iconTileGrid.maximumNumberOfColumns
    property alias columns: iconTileGrid.columns
    property alias delegateWidth: iconTileGrid.delegateWidth
    property alias delegateHeight: iconTileGrid.delegateHeight
    property alias verticalSpacing: iconTileGrid.verticalSpacing
    property alias delegate: iconTileGrid.delegate
    property alias cellWidth: iconTileGrid.cellWidth
    property alias cellHeight: iconTileGrid.cellHeight
    readonly property alias flicking: iconTileGrid.flicking
    readonly property alias moving: iconTileGrid.moving
    readonly property alias pressDelay: iconTileGrid.pressDelay

    height: childrenRect.height

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
            limit: (filter) ? collapsedRowCount * iconTileGrid.columns : -1
        }

    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: iconTileGrid.bottom
        }
        visible: (expandable && filter && model.count > collapsedRowCount * iconTileGrid.columns)
        height: (visible) ? childrenRect.height + units.gu(2) : 0

        AbstractButton {
            id: button
            objectName: "filterToggleButton"

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: units.gu(22)
            height: units.gu(4)

            UbuntuShape {
                anchors.fill: parent
                color: "#33ffffff"
                radius: "small"
            }

            UbuntuShape {
                id: borderPressed

                anchors.fill: parent
                radius: "small"
                borderSource: "radius_pressed.sci"
                opacity: button.pressed ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }
            }

            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    leftMargin: units.gu(1)
                    rightMargin: units.gu(1)
                }
                text: (filter) ? "+ View all (" + model.count + ")" : "- Show fewer"
                fontSize: "small"
                color: "#f3f3e7"
                opacity: 0.6
                style: Text.Raised
                styleColor: "black"
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignHCenter
            }

            onClicked: filter = !filter
        }
    }
}
