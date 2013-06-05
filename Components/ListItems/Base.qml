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

AbstractButton {
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
      Highlight the list item when it is pressed.
      This is used to disable the highlighting of the full list item
      when custom highlighting needs to be implemented (for example in
      ListItem.Standard which can have a split).
    */
    property bool highlightWhenPressed: true

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
        if (ListView.view !== null) {

            // if we're last item in ListView don't show divider
            if (index === ListView.view.model.count - 1) return false;
        }
        return true;
    }

    property bool __clippingRequired: ListView.view !== null
                                      && ListView.view.section.labelPositioning & ViewSection.CurrentLabelAtStart

    property real __yPositionRelativeToListView: ListView.view ? y - ListView.view.contentY : y

    property real __heightToClip: {
        // Check this is in position where clipping is needed
        if (__clippingRequired && __yPositionRelativeToListView <= __sectionDelegateHeight
                && __yPositionRelativeToListView > -height) {
            return Math.min(__sectionDelegateHeight - __yPositionRelativeToListView, height);
        } else {
            return 0;
        }
    }

    property int __sectionDelegateHeight: {
        if (__clippingRequired && ListView.view.hasOwnProperty("__sectionDelegateHeight")) {
            return ListView.view.__sectionDelegateHeight;
        } else {
            return 0;
        }
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
            pressed: (emptyListItem.selected || (emptyListItem.highlightWhenPressed && emptyListItem.pressed)) ? "pressed" : ""
        }
    }
}
