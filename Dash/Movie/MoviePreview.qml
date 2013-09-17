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
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import ".."
import "../../Components"

DashPreview {
    id: root

    property bool ready: previewData ? true : false
    property bool playable: previewData.imageSourceUri != null
    property url url: ready ? previewData.image : ""

    title: root.ready ? previewData.title : ""
    previewWidthRatio: 0.6

    onPreviewImageClicked: {
        if (playable) {
            shell.activateApplication('/usr/share/applications/mediaplayer-app.desktop', previewData.imageSourceUri);
        }
    }

    header: UbuntuShape {
        id: urlLoader
        anchors.left: parent.left
        anchors.right: parent.right
        radius: "medium"
        image: Image {
            id: previewImage
            asynchronous: true
            source: root.url
            fillMode: Image.PreserveAspectCrop
        }

        Image {
            objectName: "playButton"
            anchors.centerIn: parent
            visible: root.playable
            readonly property bool bigButton: parent.width > units.gu(40)
            width: bigButton ? units.gu(8) : units.gu(4.5)
            height: width
            source: "../graphics/play_button%1%2.png".arg(previewImageMouseArea.pressed ? "_active" : "").arg(bigButton ? "_big" : "")
        }

        MouseArea {
            id: previewImageMouseArea
            anchors.fill: parent
            onClicked: root.previewImageClicked()
        }
    }

    buttons: GridView {
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

    body: Column {
        spacing: units.gu(2)
        RatingStars {
            maximumRating: 10 // FIXME: this should happen on the backend side
            rating: ready ? previewData.rating: 0
        }

        Label {
            text: ready ? previewData.description : ""
            color: Theme.palette.selected.backgroundText
            opacity: .6
            fontSize: "medium"
            width: parent.width
            wrapMode: Text.WordWrap
            style: Text.Raised
            styleColor: "black"
        }

        Grid {
            columns: 2
            spacing: units.gu(1)
            width: parent.width
            property int firstColWidth: units.gu(9)
            property int secondColWidth: width - firstColWidth - spacing
            Label {
                visible: directedLabel.visible
                fontSize: "small"
                opacity: 0.9
                color: "white"
                horizontalAlignment: Text.AlignRight
                width: parent.firstColWidth
                text: i18n.tr("Date:")
                style: Text.Raised
                styleColor: "black"
            }
            Label {
                id: directedLabel
                visible: text != ""
                fontSize: "small"
                opacity: 0.6
                color: "white"
                width: parent.secondColWidth
                text: ready ? previewData.subtitle : ""
                style: Text.Raised
                styleColor: "black"
                wrapMode: Text.WordWrap
            }
        }

        Label {
            fontSize: "small"
            opacity: 0.6
            color: "white"
            text: {
                var parts = []
                if (ready) {
                    if (previewData.year) parts.push(previewData.year)
                }
                return parts.join(", ");
            }
            style: Text.Raised
            styleColor: "black"
        }
    }
}
