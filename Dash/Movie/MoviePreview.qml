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
import ".."
import "../Generic"
import "../../Components"
import "../Previews"

GenericPreview {
    id: root

    property bool ready: previewData ? true : false
    property url url: ready ? previewData.image : ""

    previewImages: previewImageComponent
    header: headerComponent
    actions: actionsComponent
    ratings: ratingsComponent

    Component {
        id: previewImageComponent
        UbuntuShape {
            id: urlLoader
            anchors.left: parent.left
            anchors.right: parent.right
            height: previewImage.sourceSize.width != 0 ? width * previewImage.sourceSize.height / previewImage.sourceSize.width : 0
            radius: "medium"
            visible: height > 0
            image: Image {
                id: previewImage
                asynchronous: true
                source: root.url
                fillMode: Image.PreserveAspectCrop
            }

            Image {
                objectName: "playButton"
                anchors.centerIn: parent
                readonly property bool bigButton: parent.width > units.gu(40)
                width: bigButton ? units.gu(8) : units.gu(4.5)
                height: width
                source: "../graphics/play_button%1%2.png".arg(previewImageMouseArea.pressed ? "_active" : "").arg(bigButton ? "_big" : "")
            }

            MouseArea {
                id: previewImageMouseArea
                anchors.fill: parent
                onClicked: {
                    Qt.openUrlExternally(previewData.result.uri);
                }
            }
        }
    }

    Component {
        id: headerComponent
        Header {
            title: previewData.title
            rating: Math.round(root.previewData.rating * 10)
            reviews: root.previewData.numRatings
            rated: root.previewData.infoMap["rated"] ? root.previewData.infoMap["rated"].value : 0
        }
    }

    Component {
        id: actionsComponent
        GridView {
            id: buttons
            objectName: "gridButtons"
            model: root.previewData.actions
            interactive: false

            anchors.left: parent.left
            anchors.right: parent.right

            property int numOfRows: (count + numOfColumns - 1) / numOfColumns
            property int numOfColumns: Math.max(1, Math.floor(width / (buttonWidth + spacing)))
            property int spacing: units.gu(1)
            height: Math.max(units.gu(4), units.gu(4)*numOfRows + spacing*(numOfRows - 1))

            cellWidth: width / buttons.numOfColumns
            cellHeight: buttonHeight + buttons.spacing
            property int buttonWidth: units.gu(17) - spacing
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
                    root.previewData.execute(modelData.id, { })
                }
            }
            focus: false
        }
    }
}
