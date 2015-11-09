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

/*! \brief Preview widget for editable rating.

    Shows a single display rating that can be switched by the user to edit mode
    and then behaves as a rating display widget

    The display part uses widgetData["author"], widgetData["review"] and widgetData["rating"].

    The edit part uses the same fields as the "rating-input" widget
*/

PreviewWidget {
    id: root
    implicitHeight: display.visible ? display.implicitHeight : input.implicitHeight

    Button {
        id: editIcon
        objectName: "editButton"

        iconName: "edit"
        width: height
        anchors.right: parent.right
        visible: display.visible
        onClicked: display.visible = false
    }

    PreviewRatingSingleDisplay {
        id: display
        objectName: "display"

        anchors.left: parent.left
        anchors.right: editIcon.left

        rating: widgetData["rating"] || -1
        author: widgetData["author"] || ""
        review: widgetData["review"] || ""
        urlIconEmpty: widgetData["rating-icon-empty"]
        urlIconFull: widgetData["rating-icon-full"]
        urlIconHalf: widgetData["rating-icon-half"]
        labelColor: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
    }

    PreviewRatingInput {
        id: input
        objectName: "input"

        visible: !display.visible
        width: parent.width

        widgetId: root.widgetId
        widgetData: root.widgetData
        isCurrentPreview: root.isCurrentPreview
        scopeStyle: root.scopeStyle

        ratingValue: widgetData["rating"]
        reviewText: widgetData["review"]

        onTriggered: root.triggered(widgetId, actionId, data);
    }

}
