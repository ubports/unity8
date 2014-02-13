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
        if (((widgetData["required"] === "both" ||
              widgetData["required"] === "rating") &&
             rating.value < 0) ||
            ((widgetData["required"] === "both" ||
              widgetData["required"] === "review") &&
             reviewField.text === "")) return;

        var data = {"rating": rating.value, "review": reviewField.text, "author": null};
        triggered(root.widgetId, widgetData["required"], data);
    }

    Item {
        id: ratingLabelAndWidgetContainer
        anchors {
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height
        visible: widgetData["visible"] !== "review"

        Label {
            objectName: "ratingLabel"
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            color: Theme.palette.selected.backgroundText
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
            color: Theme.palette.selected.backgroundText
            opacity: .8
            text: widgetData["review-label"] || i18n.tr("Add a review")
        }

        Item {
            anchors {
                top: reviewLabel.bottom
                left: parent.left
                right: parent.right
                topMargin: reviewContainer.innerMargin
            }
            implicitHeight: childrenRect.height

            TextField {
                id: reviewField
                objectName: "reviewField"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: submitButton.left
                    rightMargin: reviewContainer.innerMargin
                }
            }

            Button {
                id: submitButton
                objectName: "submitButton"

                readonly property bool readyToSubmit: {
                    if (reviewField.text === "" ||
                        (widgetData["visible"] === "both" && rating.value < 0)) return false;
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
