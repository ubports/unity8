/*
 * Copyright (C) 2012-2014 Canonical, Ltd.
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

Item {
    width: parent.width
    height: body.height

    /* Relevant really only for ListViewWithPageHeader case: specify how many pixels we can overlap with the section header */
    readonly property int allowedOverlap: units.dp(1)

    property real heightToClip: 0
    readonly property real __heightToClip: heightToClip >= allowedOverlap ? heightToClip - allowedOverlap : 0


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
                bottom: parent.bottom
            }
            height: childrenRect.height
        }
    }
}
