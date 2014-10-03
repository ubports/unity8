/*
 * Copyright (C) 2012 Canonical, Ltd.
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

Item {
    id: emptyListItem
    width: parent ? parent.width : units.gu(31)
    height: body.height + bottomDividerLine.height

    /*!
      \preliminary
      Specifies whether the list item is selected.
     */
    property bool selected: false

    /*!
      \preliminary
      Set to show or hide the thin bottom divider line (drawn by the \l ThinDivider component).
      This line is shown by default except in cases where this item is the delegate of a ListView.
     */
    property bool showDivider: __showDivider()

    /*!
      \internal
      Method to automatically determine if the bottom divider line should be drawn.
      This always returns true, unless item is a delegate in a ListView. If in a ListView
      it will return false only when:
       + if this is the final item in the list, and ListView.footer is set (again as thin
         divider line won't look well with footer below it)
     */
    function __showDivider() {
        // if we're not in ListView, always show a thin dividing line at the bottom
        var model = null;
        if (typeof ListViewWithPageHeader !== 'undefined') {
            if (typeof ListViewWithPageHeader.model !== 'undefined') {
                model = ListViewWithPageHeader.model;
            }
        } else if (ListView.view !== null) {
            model = ListView.view.model;
        }
            // if we're last item in ListView don't show divider
        if (model && index === model.count - 1) return false;

        return true;
    }

    /* Relevant really only for ListViewWithPageHeader case: specify how many pixels we can overlap with the section header */
    readonly property int allowedOverlap: units.dp(1)

    property real __heightToClip: {
        // Check this is in position where clipping is needed
        if (typeof ListViewWithPageHeader !== 'undefined') {
            if (typeof heightToClip !== 'undefined') {
                if (heightToClip >= allowedOverlap) {
                    return heightToClip - allowedOverlap;
                }
            }
        }
        return 0;
    }

    /*!
      \internal
      Reparent so that the visuals of the children does not
      occlude the bottom divider line.
     */
    default property alias children: body.children

    Item {
        id: clippingContainer
        height: parent.height - __heightToClip
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        clip: __heightToClip > 0

        Item {
            id: body
            anchors {
                left: parent.left
                right: parent.right
                bottom: bottomDividerLine.top
            }
            height: childrenRect.height
        }

        ThinDivider {
            id: bottomDividerLine
            anchors.bottom: parent.bottom
            visible: showDivider
        }

        Highlight {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: bottomDividerLine.top
            }
            pressed: emptyListItem.selected
        }
    }
}
