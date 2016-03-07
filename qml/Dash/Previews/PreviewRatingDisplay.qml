/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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

    onParentFlickableChanged: ratingsList.updateRanges();

    Connections {
        target: parentFlickable
        onOriginYChanged: ratingsList.updateRanges();
        onContentYChanged: ratingsList.updateRanges();
        onHeightChanged: ratingsList.updateRanges();
        onContentHeightChanged: ratingsList.updateRanges();
    }

    ListView {
        id: ratingsList
        anchors { left: parent.left; right: parent.right; }
        height: contentHeight
        interactive: false

        model: root.widgetData["reviews"]

        delegate: PreviewRatingSingleDisplay {
            id: prsd
            objectName: "reviewItem" + index

            anchors { left: parent.left; right: parent.right; }

            rating: modelData["rating"] || -1
            author: modelData["author"] || ""
            review: modelData["review"] || ""
            urlIconEmpty: widgetData["rating-icon-empty"]
            urlIconFull: widgetData["rating-icon-full"]
            urlIconHalf: widgetData["rating-icon-half"]
            labelColor: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
        }

        onContentHeightChanged: ratingsList.updateRanges();

        function updateRanges() {
            var baseItem = root.parent;
            if (!parentFlickable || !baseItem) {
                ratingsList.displayMarginBeginning = 0;
                ratingsList.displayMarginEnd = 0;
                return;
            }

            if (parentFlickable.moving) {
                // Do not update the range if we are overshooting up or down, since we'll come back
                // to the stable position and delete/create items without any reason
                if (parentFlickable.contentY < parentFlickable.originY) {
                    return;
                } else if (parentFlickable.contentHeight - parentFlickable.originY > parentFlickable.height &&
                            parentFlickable.contentY + parentFlickable.height > parentFlickable.contentHeight) {
                    return;
                }
            }

            // A item view creates its delegates synchronously from
            //     -displayMarginBeginning
            // to
            //     height + displayMarginEnd
            // Around that area it adds the cacheBuffer area where delegates are created async
            //
            // We adjust displayMarginEnd to be negative so that the range of created delegates matches
            // from the beginning of the list to the end of the viewport.
            // Ideally we would also use displayMarginBeginning
            // so that delegates at the beginning get destroyed but that causes issues with
            // listview and is not really necessary to provide the better experience we're after
            var itemYOnViewPort = baseItem.y - parentFlickable.contentY;
            var displayMarginEnd = -ratingsList.contentHeight + parentFlickable.height - itemYOnViewPort;
            displayMarginEnd = -Math.max(-displayMarginEnd, 0);
            displayMarginEnd = -Math.min(-displayMarginEnd, ratingsList.contentHeight);
            displayMarginEnd = Math.round(displayMarginEnd);

            ratingsList.displayMarginEnd = displayMarginEnd;
        }
    }
}
