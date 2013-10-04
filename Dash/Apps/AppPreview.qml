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
import Ubuntu.Components.ListItems 0.1 as ListItems
import ".."
import "../Generic"
import "../Previews"
import "../../Components"

GenericPreview {
    id: root

    signal sendUserReview(string review)

    previewImages: previewImagesComponent
    description: descriptionComponent
    header: headerComponent

    // TODO: Ratings are not yet complete... enable this once they work
    //ratings: ratingsComponent

    Component {
        id: previewImagesComponent
        ListView {
            id: previewImageListView
            spacing: units.gu(1)
            orientation: ListView.Horizontal
            height: units.gu(22)
            model: previewData.infoMap["more-screenshots"] != null ? previewData.infoMap["more-screenshots"].value : [previewData.image]
            cacheBuffer: width * 3

            // FIXME: Because of ListViews inside ListViews inside Flickables inside ListViews (and some more)
            // we finally reached the point where this ListView doesn't correctly get swipe input any more but
            // instead the parent ListView is the one that is swiped. This MouseArea sort of creates a blocking
            // layer to make sure this ListView can be swiped, regardless of what's behind it.
            MouseArea {
                anchors.fill: parent
                enabled: parent.contentWidth > parent.width
            }

            LazyImage {
                objectName: "placeholderScreenshot"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                scaleTo: "height"
                source: "broken_image"
                initialWidth: units.gu(13)
                visible: previewImageListView.count == 0
            }

            delegate: LazyImage {
                id: shape
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                source: modelData ? modelData : ""
                scaleTo: "height"
                initialWidth: units.gu(13)
            }
        }
    }

    Component {
        id: headerComponent
        Header {
            objectName: "previewHeader"
            title: previewData.title
            icon: previewData.appIcon
            subtitle: root.previewData.infoMap["publisher"] ? root.previewData.infoMap["publisher"].value : ""
            rating: Math.round(root.previewData.rating * 10)
            reviews: root.previewData.numRatings
            rated: root.previewData.infoMap["rated"] ? root.previewData.infoMap["rated"].value : 0
        }
    }

    Component {
        id: descriptionComponent
        Column {
            spacing: units.gu(1)

            Label {
                anchors { left: parent.left; right: parent.right }
                text: root.previewData.description
                fontSize: "medium"
                color: Theme.palette.selected.backgroundText
                opacity: .6
                wrapMode: Text.WordWrap
                style: Text.Raised
                styleColor: "black"
            }
        }
    }

    Component {
        id: ratingsComponent
        Column {
            id: columnReviewRating
            objectName: "columnReviewRating"
            visible: root.previewData.rating >= 0

            spacing: units.gu(1)
            height: childrenRect.height

            ListItems.ThinDivider { }

            Item {
                anchors { left: parent.left; right: parent.right }
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

                // FIXME these need to be made interactive and connected to the scope
                RatingStars {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListItems.ThinDivider { }

            Reviews {
                id: appReviews
                objectName: "appReviews"

                anchors { left: parent.left; right: parent.right }

                model: root.previewData.infoMap["comments"] ? root.previewData.infoMap["comments"].value : undefined

                onSendReview: root.sendUserReview(review);

                onEditing: {
                    root.ensureVisible(appReviews.textArea);
                }
            }
        }
    }
}
