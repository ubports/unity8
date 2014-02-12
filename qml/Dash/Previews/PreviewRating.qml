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

/*! \brief Preview widget for rating. */

PreviewWidget {
    id: root

    function submit() {
        // checks rating-input requirements
        if ((widgetData["required"] === "both" ||
             widgetData["required"] === "rating") &&
            rating.value < 0) return;
        if ((widgetData["required"] === "both" ||
             widgetData["required"] === "review") &&
            reviewTextArea.text === "") return;

        var data = [{"rating": rating.value, "review": reviewTextArea.text, "author": null}]
        triggered(root.widgetId, null, data)
    }

    Item {
        id: ratingLabelAndWidgetContainer
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }
        height: childrenRect.height
        visible: widgetData["visible"] !== "review"

        Label {
            anchors {
                top: parent.top
                left: parent.left
            }
            color: Theme.palette.selected.backgroundText
            opacity: .8
            text: widgetData["review-label"]
        }

        Rating {
            id: rating
            anchors {
                top: parent.top
                right: parent.right
            }
            size: 5
            onValueChanged: submit()
        }
    }

    TextArea {
        id: reviewTextArea
        anchors {
            left: parent.left
            right: parent.right
            top: ratingLabelAndWidgetContainer.visible ? ratingLabelAndWidgetContainer.bottom : parent.top
            bottom: parent.bottom
        }
        visible: widgetData["visible"] !== "rating"
        color: Theme.palette.selected.backgroundText
    }
}
