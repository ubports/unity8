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
import "../../Components"

Row {
    id: root
    property alias icon: image.source
    property alias appName: appNameLabel.text
    property alias rating: ratingStars.rating
    property int rated: 0
    property int reviews: 0
    property bool displayRatings: rating >= 0

    spacing: units.gu(2)

    UbuntuShape {
        id: imageShape
        width: units.gu(6)
        height: units.gu(6)
        image: Image {
            id: image
            sourceSize { width: imageShape.width; height: imageShape.height }
            asynchronous: true
            fillMode: Image.PreserveAspectFit
        }
    }

    Column {
        spacing: units.gu(1)

        Label {
            id: appNameLabel
            fontSize: "large"
            color: "white"
            style: Text.Raised
            styleColor: "black"
            opacity: .9
        }

        Row {
	    visible: root.displayRatings
            spacing: units.gu(1)

            RatingStars {
                id: ratingStars
                maximumRating: 10
            }

            Label {
                id: ratedLabel
                objectName: "ratedLabel"
                fontSize: "medium"
                color: "white"
                style: Text.Raised
                styleColor: "black"
                opacity: .6
                //TRANSLATORS: Number of persons who rated this app
                text: i18n.tr("(%1)").arg(root.rated)
            }

            Label {
                id: reviewsLabel
                objectName: "reviewsLabel"
                fontSize: "medium"
                color: "white"
                style: Text.Raised
                styleColor: "black"
                opacity: .6
                //TRANSLATORS: Number of persons who wrote reviews for this app
                text: i18n.tr("%1 review", "%1 reviews", root.reviews).arg(root.reviews)
            }
        }
    }
}
