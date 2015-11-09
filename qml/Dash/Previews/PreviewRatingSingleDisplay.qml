/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import "../../Components"

Column {
    id: reviewItem
    spacing: units.gu(1)

    property alias rating: ratingItem.value
    property alias author: authorLabel.text
    property alias review: reviewLabel.text
    property alias urlIconEmpty: ratingItem.urlIconEmpty
    property alias urlIconFull: ratingItem.urlIconFull
    property alias urlIconHalf: ratingItem.urlIconHalf
    property alias labelColor: authorLabel.color

    Rating {
        id: ratingItem
        objectName: "rating"
        size: 5
        visible: value >= 0
        interactive: false

        property var urlIconEmpty
        property var urlIconFull
        property var urlIconHalf
    }

    Label {
        id: authorLabel
        objectName: "authorLabel"
        anchors { left: parent.left; right: parent.right }
        opacity: .8
        visible: text !== ""
        wrapMode: Text.Wrap
    }

    Label {
        id: reviewLabel
        objectName: "reviewLabel"
        anchors { left: parent.left; right: parent.right }
        color: authorLabel.color
        opacity: .8
        visible: text !== ""
        wrapMode: Text.Wrap
    }

    Item {
        id: spacing
        anchors { left: parent.left; right: parent.right }
        height: units.gu(2)
        visible: rating.visible || authorLabel.visible || reviewLabel.visible
    }
}