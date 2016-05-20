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
                return ratingLabelAndWidgetContainer.implicitHeight + (reviewContainer.visible ? reviewContainer.implicitHeight : 0);
            case "rating":
                return ratingLabelAndWidgetContainer.implicitHeight;
            case "review":
                return reviewContainer.implicitHeight;
        }
    }

    clip: reviewContainer.visible

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

    Column {
        id: ratingLabelAndWidgetContainer
        anchors { left: parent.left; right: parent.right; }
        spacing: units.gu(0.5)
        visible: widgetData["visible"] !== "review"

        Label {
            id: ratingLabel
            objectName: "ratingLabel"
            anchors { left: parent.left; right: parent.right; }
            fontSize: "large"
            color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText
            opacity: .8
            text: widgetData["rating-label"] || i18n.tr("Rate this")
        }

        Rating {
            id: rating
            objectName: "rating"
            anchors.left: parent.left
            size: 5
            height: units.gu(4)
            onValueChanged: {
                if (widgetData["visible"] === "rating") root.submit();
            }

            property var urlIconEmpty: widgetData["rating-icon-empty"] || "image://theme/non-starred"
            property var urlIconFull: widgetData["rating-icon-full"] || "image://theme/starred"
        }
    }

    Item {
        id: reviewContainer
        objectName: "reviewContainer"
        implicitHeight: visible ? reviewSubmitContainer.implicitHeight + anchors.topMargin : 0

        readonly property real innerMargin: units.gu(1)

        anchors {
            left: parent.left
            right: parent.right
            top: ratingLabelAndWidgetContainer.visible ? ratingLabelAndWidgetContainer.bottom : parent.top
            bottom: parent.bottom
            topMargin: ratingLabelAndWidgetContainer.visible ? innerMargin : 0
        }
        visible: {
            switch(widgetData["visible"]) {
                default:
                case "both":
                    return widgetData["required"] === "review" || rating.value > 0;
                case "rating":
                    return false;
                case "review":
                    return true;
            }
        }

        Behavior on implicitHeight {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.FastDuration
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: reviewSubmitContainer
            objectName: "reviewSubmitContainer"
            anchors.fill: parent
            implicitHeight: reviewTextArea.implicitHeight + anchors.topMargin

            TextArea {
                id: reviewTextArea
                objectName: "reviewTextArea"
                property bool inputMethodVisible: Qt.inputMethod.visible
                onInputMethodVisibleChanged: {
                    if(inputMethodVisible && activeFocus)
                        root.makeSureVisible(reviewTextArea);
                }
                onVisibleChanged: {
                    if (visible && widgetData["visible"] !== "review")
                        focus = true;
                }
                anchors {
                    top: parent.top
                    left: parent.left
                    right: submitButton.left
                    rightMargin: reviewContainer.innerMargin
                }
                placeholderText: widgetData["review-label"] || i18n.tr("Add a review")
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
                enabled: readyToSubmit
                text: widgetData["submit-label"] || i18n.tr("Send")
                onClicked: root.submit()
            }
        }
    }
}
