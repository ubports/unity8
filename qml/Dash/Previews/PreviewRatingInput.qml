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

/*! \brief Preview widget for rating.

    The widget can show a rating widget and a field to enter a comment.
    The visibility of the two widgets is specified by widgetData["visible"],
    accepting "both", "rating" or "review".
    The requirement of the review is specified by widgetData["visible"],
    accepting "both", "rating" or "review".
    It is possible to customise labels, widgetData["rating-label"] for the rating,
    widgetData["rewiew-label"] for the comment field and widgetData["submit-label"]
    for the submit button.
    The icons used in the rating widget can be customised with
    widgetData["rating-icon-empty"] and widgetData["rating-icon-full"].
    The successeful submit emits triggered(widgetId, widgetData["required"], data),
    with data being {"rating": rating value, "review": review comment, "author": null (for now)}.
*/

PreviewWidget {
    id: root
    implicitHeight: {
        switch(widgetData["visible"]) {
            default:
            case "both":
                return ratingLabelAndWidgetContainer.implicitHeight + reviewContainer.implicitHeight;
            case "rating":
                return ratingLabelAndWidgetContainer.implicitHeight;
            case "review":
                return reviewContainer.implicitHeight;
            }
    }

    property alias ratingValue: rating.value
    property alias reviewText: reviewTextArea.text

    function submit() {
        // checks rating-input requirements
        if (((widgetData["required"] === "both" ||
              widgetData["required"] === "rating") &&
             rating.value < 0) ||
            ((widgetData["required"] === "both" ||
              widgetData["required"] === "review") &&
             reviewTextArea.text === "")) return;

        var data = {"rating": rating.value, "review": reviewTextArea.text, "author": null};
        triggered(root.widgetId, "rated", data);
    }

    Item {
        id: ratingLabelAndWidgetContainer
        anchors {
            left: parent.left
            right: parent.right
        }
        implicitHeight: rating.height
        visible: widgetData["visible"] !== "review"

        Label {
            objectName: "ratingLabel"
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            color: root.scopeStyle ? root.scopeStyle.foreground : Theme.palette.normal.baseText
            opacity: .8
            text: widgetData["rating-label"] || i18n.tr("Rate this")
        }

        Rating {
            id: rating
            objectName: "rating"
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            size: 5
            onValueChanged: {
                if (widgetData["visible"] === "rating") root.submit();
            }

            property var urlIconEmpty: widgetData["rating-icon-empty"]
            property var urlIconFull: widgetData["rating-icon-full"]
        }
    }

    Item {
        id: reviewContainer
        implicitHeight: reviewLabel.implicitHeight + reviewSubmitContainer.implicitHeight + anchors.topMargin

        readonly property real innerMargin: units.gu(1)

        anchors {
            left: parent.left
            right: parent.right
            top: ratingLabelAndWidgetContainer.visible ? ratingLabelAndWidgetContainer.bottom : parent.top
            bottom: parent.bottom
            topMargin: ratingLabelAndWidgetContainer.visible ? reviewContainer.innerMargin : 0
        }
        visible: widgetData["visible"] !== "rating"

        Label {
            objectName: "reviewLabel"
            id: reviewLabel
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            color: root.scopeStyle ? root.scopeStyle.foreground : Theme.palette.normal.baseText
            opacity: .8
            text: widgetData["review-label"] || i18n.tr("Add a review")
        }

        Item {
            id: reviewSubmitContainer
            anchors {
                top: reviewLabel.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: reviewContainer.innerMargin
            }
            implicitHeight: reviewTextArea.implicitHeight + anchors.topMargin

            TextArea {
                id: reviewTextArea
                objectName: "reviewTextArea"
                property bool inputMethodVisible: Qt.inputMethod.visible
                onInputMethodVisibleChanged: {
                    if(inputMethodVisible && activeFocus)
                        root.makeSureVisible(reviewTextArea);
                }
                anchors {
                    top: parent.top
                    left: parent.left
                    right: submitButton.left
                    rightMargin: reviewContainer.innerMargin
                }
            }

            Button {
                id: submitButton
                objectName: "submitButton"

                readonly property bool readyToSubmit: {
                    if ((widgetData["required"] !== "review" && rating.value < 0) ||
                        (widgetData["required"] !== "rating" && reviewTextArea.text === "")) return false;
                    else return true;
                }

                anchors {
                    top: parent.top
                    right: parent.right
                }
                color: readyToSubmit ? Theme.palette.selected.base : Theme.palette.normal.base
                text: widgetData["submit-label"] || i18n.tr("Send")
                onClicked: {
                    if (readyToSubmit) root.submit()
                }
            }
        }
    }
}
