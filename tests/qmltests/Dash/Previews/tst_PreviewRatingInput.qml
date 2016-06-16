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

    property real validInputRating: 1
    property real invalidInputRating: -1
    property string validInputText: "Great!"
    property string invalidInputText: ""

    property var triggeredDataBoth: { "rating": validInputRating, "review": validInputText, "author": null }
    property var triggeredDataRatingOnly: { "rating": validInputRating, "review": invalidInputText, "author": null }
    property var triggeredDataReviewOnly: { "rating": invalidInputRating, "review": validInputText, "author": null }

    property var widgetDataBoth: { "visible": "both", "required": "both" }
    property var widgetDataBothRequireRating: { "visible": "both", "required": "rating" }
    property var widgetDataBothRequireReview: { "visible": "both", "required": "review" }
    property var widgetDataRating: { "visible": "rating", "required": "rating" }
    property var widgetDataRatingBroken: { "visible": "rating", "required": "review" }
    property var widgetDataReview: { "visible": "review", "required": "review" }
    property var widgetDataReviewBroken: { "visible": "review", "required": "rating" }

    property var widgetDataNewLabels: { "visible": "both", "required": "both", "rating-label": "TestRatingLabel", "review-label": "TestReviewLabel", "submit-label": "TestSubmitLabel" }

    PreviewRatingInput {
        id: previewRatingInput
        anchors.left: parent.left
        anchors.right: parent.right
        widgetData: widgetDataBoth
        widgetId: "previewRatingInput"
    }

    SignalSpy {
        id: spy
        signalName: "triggered"
    }

    UT.UnityTestCase {
        name: "PreviewRatingInputTest"
        when: windowShown

        property var rating: findChild(previewRatingInput, "rating")
        property var reviewTextArea: findChild(previewRatingInput, "reviewTextArea")
        property var submitButton: findChild(previewRatingInput, "submitButton")

        function init() {
            rating.value = -1;
            reviewTextArea.text = "";
        }

        function test_labels() {
            var ratingLabel = findChild(previewRatingInput, "ratingLabel");

            previewRatingInput.widgetData = widgetDataNewLabels;
            compare(ratingLabel.text, widgetDataNewLabels["rating-label"]);
            compare(reviewTextArea.placeholderText, widgetDataNewLabels["review-label"]);
            compare(submitButton.text, widgetDataNewLabels["submit-label"]);
        }

        function test_submit_and_visibility_data() {
            return [
                {tag: "both, null review", widgetData: widgetDataBoth, inputRating: invalidInputRating, inputText: invalidInputText, emitted: false},
                {tag: "both, rating-only review", widgetData: widgetDataBoth, inputRating: validInputRating, inputText: invalidInputText, emitted: false},
                {tag: "both, review-only review", widgetData: widgetDataBoth, inputRating: invalidInputRating, inputText: validInputText, emitted: false},
                {tag: "both, complete review", widgetData: widgetDataBoth, inputRating: validInputRating, inputText: validInputText, emitted: true},
                {tag: "both require rating, null review", widgetData: widgetDataBothRequireRating, inputRating: invalidInputRating, inputText: invalidInputText, emitted: false},
                {tag: "both require rating, rating-only review", widgetData: widgetDataBothRequireRating, inputRating: validInputRating, inputText: invalidInputText, emitted: true},
                {tag: "both require rating, review-only review", widgetData: widgetDataBothRequireRating, inputRating: invalidInputRating, inputText: validInputText, emitted: false},
                {tag: "both require rating, complete review", widgetData: widgetDataBothRequireRating, inputRating: validInputRating, inputText: validInputText, emitted: true},
                {tag: "both require review, null review", widgetData: widgetDataBothRequireReview, inputRating: invalidInputRating, inputText: invalidInputText, emitted: false},
                {tag: "both require review, rating-only review", widgetData: widgetDataBothRequireReview, inputRating: validInputRating, inputText: invalidInputText, emitted: false},
                {tag: "both require review, review-only review", widgetData: widgetDataBothRequireReview, inputRating: invalidInputRating, inputText: validInputText, emitted: true},
                {tag: "both require review, complete review", widgetData: widgetDataBothRequireReview, inputRating: validInputRating, inputText: validInputText, emitted: true},
                {tag: "rating, null review", widgetData: widgetDataRating, inputRating: invalidInputRating, inputText: invalidInputText, emitted: false},
                {tag: "rating, rating-only review", widgetData: widgetDataRating, inputRating: validInputRating, inputText: invalidInputText, emitted: true},
                {tag: "rating, review-only review", widgetData: widgetDataRating, inputRating: invalidInputRating, inputText: validInputText, emitted: false},
                {tag: "rating, complete review", widgetData: widgetDataRating, inputRating: validInputRating, inputText: validInputText, emitted: true},
                {tag: "rating broken, null review", widgetData: widgetDataRatingBroken, inputRating: invalidInputRating, inputText: invalidInputText, emitted: false},
                {tag: "rating broken, rating-only review", widgetData: widgetDataRatingBroken, inputRating: validInputRating, inputText: invalidInputText, emitted: false},
                {tag: "rating broken, review-only review", widgetData: widgetDataRatingBroken, inputRating: invalidInputRating, inputText: validInputText, emitted: false},
                {tag: "rating broken, complete review", widgetData: widgetDataRatingBroken, inputRating: validInputRating, inputText: validInputText, emitted: false},
                {tag: "review, null review", widgetData: widgetDataReview, inputRating: invalidInputRating, inputText: invalidInputText, emitted: false},
                {tag: "review, rating-only review", widgetData: widgetDataReview, inputRating: validInputRating, inputText: invalidInputText, emitted: false},
                {tag: "review, review-only review", widgetData: widgetDataReview, inputRating: invalidInputRating, inputText: validInputText, emitted: true},
                {tag: "review, complete review", widgetData: widgetDataReview, inputRating: validInputRating, inputText: validInputText, emitted: true},
                {tag: "review broken, null review", widgetData: widgetDataReviewBroken, inputRating: invalidInputRating, inputText: invalidInputText, emitted: false},
                {tag: "review broken, rating-only review", widgetData: widgetDataReviewBroken, inputRating: validInputRating, inputText: invalidInputText, emitted: false},
                {tag: "review broken, review-only review", widgetData: widgetDataReviewBroken, inputRating: invalidInputRating, inputText: validInputText, emitted: false},
                {tag: "review broken, complete review", widgetData: widgetDataReviewBroken, inputRating: validInputRating, inputText: validInputText, emitted: false},
            ];
        }

        function test_submit_and_visibility(data) {
            spy.clear();
            spy.target = previewRatingInput;

            previewRatingInput.widgetData = data.widgetData;

            if (data.widgetData["visible"] === "both" && data.widgetData["required"] === "both")
                compare(reviewTextArea.visible, false);

            if (data.widgetData["visible"] !== "review") {
                compare(rating.visible, true);

                rating.value = data.inputRating;

                if (data.inputRating > 0 && data.widgetData["visible"] === "both")
                    compare(reviewTextArea.visible, true);

                if (data.widgetData["required"] !== "rating" ||
                    data.widgetData["visible"] !== "rating" ||
                    data.inputRating < 0) {
                    compare(spy.count, 0);
                } else {
                    compare(spy.count, 1);
                }
            } else {
                compare(rating.visible, false);
            }

            if (data.widgetData["visible"] !== "rating") {
                if (data.widgetData["visible"] === "review" || data.widgetData["required"] === "review")
                    compare(reviewTextArea.visible, true);

                reviewTextArea.text = data.inputText;
                var reviewContainer = findChild(previewRatingInput, "reviewContainer");
                if (reviewContainer.visible) {
                    var reviewSubmitContainer = findChild(previewRatingInput, "reviewSubmitContainer");
                    tryCompare(reviewContainer, "implicitHeight", reviewSubmitContainer.implicitHeight + reviewContainer.anchors.topMargin);
                }
                mouseClick(submitButton);
                switch (data.widgetData["required"]) {
                    case "rating": {
                        if (rating.visible === false || data.inputRating < 0) {
                            compare(spy.count, 0);
                        } else {
                            compare(spy.count, 1);
                        }
                        break;
                    }
                    case "both":
                    default: {
                        if (data.inputRating < 0 || data.inputText === "") {
                            compare(spy.count, 0); break;
                        }
                    }
                    case "review": {
                        if (data.inputText === "") {
                            compare(spy.count, 0); break;
                        } else {
                            compare(spy.count, 1); break;
                        }
                    }
                }
            } else {
                compare(reviewTextArea.visible, false);
            }

            compare(spy.count === 1, data.emitted);
        }

        function test_triggered_data() {
            return [
                {tag: "complete review", widgetData: widgetDataBoth, inputRating: validInputRating, inputText: validInputText, triggeredData: triggeredDataBoth},
                {tag: "rating-only review", widgetData: widgetDataRating, inputRating: validInputRating, inputText: invalidInputText, triggeredData: triggeredDataRatingOnly},
                {tag: "review-only review", widgetData: widgetDataReview, inputRating: invalidInputRating, inputText: validInputText, triggeredData: triggeredDataReviewOnly}
            ];
        }

        function test_triggered(data) {
            spy.clear();
            spy.target = previewRatingInput;

            previewRatingInput.widgetData = data.widgetData;

            if (data.inputRating > 0) rating.value = data.inputRating;
            if (data.inputText !== "") {
                reviewTextArea.text = data.inputText;
                mouseClick(submitButton);
            }

            compare(spy.count, 1);
            var args = spy.signalArguments[0];
            compare(args[0], previewRatingInput.widgetId);
            compare(args[1], "rated");
            compare(args[2]["rating"], data.triggeredData["rating"]);
            compare(args[2]["review"], data.triggeredData["review"]);
            verify(args[2]["author"] !== undefined); // Just verifying it exists now
        }
    }
}
