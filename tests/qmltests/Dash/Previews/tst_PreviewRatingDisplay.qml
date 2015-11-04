/*
 * Copyright 2014,2015 Canonical Ltd.
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
import QtTest 1.0
import Ubuntu.Components 1.3
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: theme.palette.selected.background

    property var reviewsModel0: {
        "reviews": [ ]
    }

    property var reviewsModel1: {
        "reviews": [ { author: "Some dude", rating: 4.5, review: "Very cool app" },
                     { author: "Yet Another dude", rating: 5, review: "Very cool app" }, ]
    }

    property var reviewsModel2: {
        "reviews": [ { author: "Some dude", rating: 4.5, review: "Very cool app" },
                     { author: "Another dude", rating: 3, review: "Average app. Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh." },
                     { author: "Yet Another dude", rating: 5, review: "Very cool app" }, ]
    }

    property var reviewsModelMixed: {
        "reviews": [ { author: "Some dude", review: "Very cool app" },
                     { author: "" },
                     { rating: 3, review: "Average app. Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh." },
                     { author: "Yet Another dude", rating: 5 }, ]
    }

    PreviewRatingDisplay {
        id: previewRatingDisplay
        anchors.left: parent.left
        anchors.right: parent.right
        widgetData: reviewsModelMixed
    }

    UT.UnityTestCase {
        name: "PreviewRatingDisplayTest"
        when: windowShown

        function test_reviews_data() {
            return [
                    {tag: "0 reviews", reviewsModel: reviewsModel0},
                    {tag: "1 review", reviewsModel: reviewsModel1},
                    {tag: "3 reviews", reviewsModel: reviewsModel2},
                    {tag: "3 mixed reviews", reviewsModel: reviewsModelMixed}
            ];
        }

        function test_reviews(data) {
            previewRatingDisplay.widgetData = data.reviewsModel;

            var reviewsRepeater = findChild(previewRatingDisplay, "reviewsRepeater");
            compare(reviewsRepeater.count, data.reviewsModel["reviews"].length);

            for (var i = 0; i < data.reviewsModel["reviews"].length; ++i) {
                var reviewItem = findChild(previewRatingDisplay, "reviewItem" + i);

                var rating = findChild(reviewItem, "rating");
                if (data.reviewsModel["reviews"][i]["rating"] >= 0) {
                    compare(rating.visible, true);
                    compare(rating.value, data.reviewsModel["reviews"][i]["rating"]);
                } else {
                    compare(rating.visible, false);
                }

                var authorLabel = findChild(reviewItem, "authorLabel");
                if (data.reviewsModel["reviews"][i]["author"] &&
                    data.reviewsModel["reviews"][i]["author"] !== "") {
                    compare(authorLabel.visible, true);
                    compare(authorLabel.text, data.reviewsModel["reviews"][i]["author"]);
                } else {
                    compare(authorLabel.visible, false);
                }

                var reviewLabel = findChild(reviewItem, "reviewLabel");
                if (data.reviewsModel["reviews"][i]["review"] &&
                    data.reviewsModel["reviews"][i]["review"] !== "") {
                    compare(reviewLabel.visible, true);
                    compare(reviewLabel.text, data.reviewsModel["reviews"][i]["review"]);
                } else {
                    compare(reviewLabel.visible, false);
                }

                if (!rating.visible && !authorLabel.visible && !reviewLabel.visible) {
                    verify(reviewItem.height === 0);
                }
            }
        }

        function test_non_interactive() {
            previewRatingDisplay.widgetData = reviewsModel1;

            var reviewItem = findChild(previewRatingDisplay, "reviewItem1");
            var rating = findChild(reviewItem, "rating");

            compare(rating.value, reviewsModel1["reviews"][1]["rating"]);

            // Tap on first star
            mouseClick(rating);
            compare(rating.value, reviewsModel1["reviews"][1]["rating"]);
        }
    }
}
