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
import "../../Components"
import ".."
import "../Previews"

DashPreview {
    id: genericPreview
    property url url: previewData.image

    previewImages: previewImagesComponent
    header: headerComponent
    actions: actionsComponent
    description: descriptionComponent
    ratings: ratingsComponent

    Component {
        id: previewImagesComponent
        UbuntuShape {
            id: urlLoader
            anchors.left: parent.left
            anchors.right: parent.right
            height: width * previewImage.sourceSize.height / previewImage.sourceSize.width
            radius: "medium"
            visible: height > 0
            image: Image {
                id: previewImage
                asynchronous: true
                source: genericPreview.url
                fillMode: Image.PreserveAspectCrop
            }
        }
    }

    Component {
        id: headerComponent
        Header {
            title: previewData.title
            rating: Math.round(root.previewData.rating * 10)
            subtitle: previewData.subtitle.replace(/[\r\n]+/g, "<br />")
            reviews: root.previewData.numRatings
            rated: root.previewData.infoMap["rated"] ? root.previewData.infoMap["rated"].value : 0
        }
    }

    Component {
        id: actionsComponent
        GridView {
            id: buttons
            model: genericPreview.previewData.actions

            property int buttonMaxWidth: units.gu(34)
            property int numOfColumns: Math.ceil((width + spacing) / (buttonMaxWidth + spacing))
            property int numOfRows: Math.ceil(count / numOfColumns)
            property int spacing: units.gu(1)
            height: Math.max(units.gu(4), units.gu(4)*numOfRows + spacing*(numOfRows - 1))

            cellWidth: width / numOfColumns
            cellHeight: buttonHeight + spacing
            property int buttonWidth: cellWidth - spacing / 2
            property int buttonHeight: units.gu(4)

            delegate: Button {
                width: Math.max(units.gu(4), buttons.buttonWidth)
                height: buttons.buttonHeight
                color: "#dd4814"
                text: modelData.displayName
                iconSource: modelData.iconHint
                iconPosition: "right"
                visible: true
                onClicked: {
                    genericPreview.previewData.execute(modelData.id, { })
                }
            }
            focus: false
        }
    }

    Component {
        id: descriptionComponent
        Column {
            spacing: units.gu(2)

            Label {
                id: descriptionLabel
                anchors { left: parent.left; right: parent.right }
                visible: text != ""
                fontSize: "small"
                opacity: 0.6
                color: "white"
                text: previewData.description.replace(/[\r\n]+/g, "<br />")
                style: Text.Raised
                styleColor: "black"
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                // FIXME: workaround for https://bugreports.qt-project.org/browse/QTBUG-33020
                onWidthChanged: { wrapMode = Text.NoWrap; wrapMode = Text.WordWrap }
            }

            Column {
                id: infoItem
                anchors {
                    left: parent.left
                    right: parent.right
                }
                Repeater {
                    model: previewData.infoHints

                    delegate: Item {
                        width: parent.width
                        height: units.gu(5)
                        Row {
                            width: parent.width
                            spacing: units.gu(1)
                            property int columnWidth: (width - spacing) / 2
                            anchors.verticalCenter: parent.verticalCenter

                            Label {
                                visible: directedLabel.visible
                                fontSize: "small"
                                opacity: 0.9
                                color: "white"
                                horizontalAlignment: Text.AlignLeft
                                width: parent.columnWidth
                                text: modelData.displayName
                                style: Text.Raised
                                styleColor: "black"
                            }
                            Label {
                                id: directedLabel
                                visible: modelData.value != ""
                                fontSize: "small"
                                opacity: 0.6
                                color: "white"
                                horizontalAlignment: Text.AlignRight
                                width: parent.columnWidth
                                text: modelData.value ? modelData.value : ""
                                style: Text.Raised
                                styleColor: "black"
                                wrapMode: Text.WordWrap
                            }
                        }
                        ListItems.ThinDivider {
                            anchors {
                                left: parent.left
                                bottom: parent.bottom
                                right: parent.right
                            }
                        }
                    }
                }
            }
        }
    }
}
