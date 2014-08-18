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

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../Components"

/*! \brief Preview widget for rating display.

    The widget can show a rating widget and a field showing a comment.
    The icons used in the rating widget can be customised with
    widgetData["rating-icon-empty"], widgetData["rating-icon-full"]
    and widgetData["rating-icon-half"].

    This widget shows reviews contained in widgetData["reviews"], each of which should be of the form:

    \code{.json}
    {
      "rating": null,
      "review": null,
      "author": null
    }
    \endcode
 */

PreviewWidget {
    id: root
    height: childrenRect.height

    Column {
        anchors { left: parent.left; right: parent.right; }
        visible: reviewsRepeater.count > 0

        Repeater {
            id: reviewsRepeater
            objectName: "reviewsRepeater"
            model: root.widgetData["reviews"]

            delegate: Column {
                id: reviewItem
                objectName: "reviewItem" + index
                anchors { left: parent.left; right: parent.right;}
                spacing: units.gu(1)

                Rating {
                    id: rating
                    objectName: "rating"
                    size: 5
                    value: modelData["rating"] || -1
                    visible: value >= 0
                    interactive: false

                    property var urlIconEmpty: widgetData["rating-icon-empty"]
                    property var urlIconFull: widgetData["rating-icon-full"]
                    property var urlIconHalf: widgetData["rating-icon-half"]
                }

                Label {
                    id: authorLabel
                    objectName: "authorLabel"
                    anchors { left: parent.left; right: parent.right }
                    color: scopeStyle ? scopeStyle.foreground : Theme.palette.normal.baseText
                    opacity: .8
                    text: modelData["author"] || ""
                    visible: text !== ""
                    wrapMode: Text.Wrap
                }

                Label {
                    id: reviewLabel
                    objectName: "reviewLabel"
                    anchors { left: parent.left; right: parent.right }
                    color: scopeStyle ? scopeStyle.foreground : Theme.palette.normal.baseText
                    opacity: .8
                    text: modelData["review"] || ""
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
        }
    }
}
