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
import Ubuntu.Components.ListItems 0.1 as ListItem
import ".."
import "../../Components"

DashPreview {
    id: root

    signal download
    signal open
    signal sendUserReview(string review)

    title: "" // FROM PREVIEW DATA (FIXME: need scope format data)

    header: AppScreenshotsList {
        height: units.gu(20)

        model: 0 // FROM PREVIEW DATA (FIXME: need scope format data)
    }

    buttons: GridView {
        id: buttons
        model: root.previewData.actions

        property int numOfRows: (count + 1) / 2
        property int spacing: units.gu(1)
        height: Math.max(units.gu(4), units.gu(4)*numOfRows + spacing*(numOfRows - 1))

        cellWidth: Math.max(units.gu(9), width / 2)
        cellHeight: buttonHeight + spacing
        property int buttonWidth: Math.max(0, width / 2 - spacing)
        property int buttonHeight: units.gu(4)

        delegate: Button {
            width: Math.max(units.gu(4), buttons.buttonWidth)
            height: buttons.buttonHeight
            color: Theme.palette.selected.foreground
            text: modelData.displayName
            iconSource: modelData.iconHint
            iconPosition: "right"
            visible: true
            onClicked: {
                root.previewData.execute(modelData.id, { })
            }
        }
        focus: false
    }

    body: Column {
        spacing: units.gu(1)

        AppInfo {
            appName: "" // FROM PREVIEW DATA (FIXME: need scope format data)
            icon: "" // FROM PREVIEW DATA (FIXME: need scope format data)
            rating: 0 // FROM PREVIEW DATA (FIXME: need scope format data)
            rated: 0 // FROM PREVIEW DATA (FIXME: need scope format data)
            reviews: 0 // FROM PREVIEW DATA (FIXME: need scope format data)

            width: root.width
        }

        Label {
            text: "" // FROM PREVIEW DATA (FIXME: need scope format data)
            fontSize: "medium"
            color: Theme.palette.selected.backgroundText
            opacity: .6
            width: parent.width
            wrapMode: Text.WordWrap
            style: Text.Raised
            styleColor: "black"
        }

        ListItem.ThinDivider {}

        Item {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: rateLabel.height

            Label {
                id: rateLabel
                fontSize: "medium"
                color: "white"
                style: Text.Raised
                styleColor: "black"
                opacity: .9
                text: i18n.tr("Rate this")

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            RatingStars {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ListItem.ThinDivider {}

        AppReviews {
            anchors {
                left: parent.left
                right: parent.right
            }

            onSendReview: root.sendUserReview(review);
        }

    }
}
