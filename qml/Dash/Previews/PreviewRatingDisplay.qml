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
    implicitHeight: childrenRect.height

    Column {
        anchors { left: parent.left; right: parent.right; }
        visible: reviewsRepeater.count > 0

        Repeater {
            id: reviewsRepeater
            objectName: "reviewsRepeater"
            model: root.widgetData["reviews"]

            delegate: PreviewRatingSingleDisplay {
                objectName: "reviewItem" + index

                anchors { left: parent.left; right: parent.right; }

                rating: modelData["rating"] || -1
                author: modelData["author"] || ""
                review: modelData["review"] || ""
                urlIconEmpty: widgetData["rating-icon-empty"]
                urlIconFull: widgetData["rating-icon-full"]
                urlIconHalf: widgetData["rating-icon-half"]
                labelColor: scopeStyle ? scopeStyle.foreground : Theme.palette.normal.baseText
            }
        }
    }
}
