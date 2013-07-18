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
import "../../Components"

DashPreview {
    id: root

    property var item
    property alias ready: nfo.ready
    property bool playable: false
    readonly property url fileUri: item ? item.fileUri : ""

    VideoInfo {
        id: nfo
        source: item ? item.nfoUri : ""
    }

    title: nfo.ready ? nfo.video.title : ""
    url: item ? item.nfoUri.replace(/\.nfo$/, "-fanart.jpg") : ""
    previewWidthRatio: 0.6
    playable: fileUri != ""

    onPreviewImageClicked: {
        if (playable) {
            shell.activateApplication('/usr/share/applications/mediaplayer-app.desktop', root.fileUri);
        }
    }

    // TODO: replace this UbuntuShape with the Video component once that lands
    // with the player.
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
            source: "graphics/play_button%1%2.png".arg(previewImageMouseArea.pressed ? "_active" : "").arg(bigButton ? "_big" : "")
        }

        MouseArea {
            id: previewImageMouseArea
            anchors.fill: parent
            onClicked: root.previewImageClicked()
        }
    }

    buttons: Row {
        spacing: units.gu(2)

        property int buttonWidth: Math.min(units.gu(22), (width - spacing) / 2)
        Button {
            width: parent.buttonWidth
            color: Theme.palette.selected.foreground
            text: nfo.ready && nfo.video.buyPrice != "" ? "Buy for " + nfo.video.buyPrice : ""
            visible: text != ""
            iconSource: "graphics/icon_button_amazon.png"
            iconPosition: "right"
        }
        Button {
            width: parent.buttonWidth
            color: Theme.palette.selected.foreground
            text: nfo.ready && nfo.video.buyPrice != "" ? "Rent for " + nfo.video.rentPrice : ""
            visible: text != ""
            iconSource: "graphics/icon_button_u1.png"
            iconPosition: "right"
        }
    }

    body: Column {
        spacing: units.gu(2)
        RatingStars {
            maximumRating: 10 // FIXME: this should happen on the backend side
            rating: nfo.ready ? nfo.video.rating: 0
        }

        Label {
            text: nfo.ready ? nfo.video.plot : ""
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
                text: i18n.tr("Directed by:")
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
                text: nfo.ready ? nfo.video.director : ""
                style: Text.Raised
                styleColor: "black"
                wrapMode: Text.WordWrap
            }
            Label {
                visible: starringLabel.visible
                fontSize: "small"
                opacity: 0.9
                horizontalAlignment: Text.AlignRight
                color: "white"
                width: parent.firstColWidth
                text: i18n.tr("Starring:")
                style: Text.Raised
                styleColor: "black"
            }
            Label {
                id: starringLabel
                visible: text != ""
                fontSize: "small"
                opacity: 0.6
                color: "white"
                width: parent.secondColWidth
                text: nfo.ready ? nfo.getActors().join(", ") : ""
                wrapMode: Text.WordWrap
                style: Text.Raised
                styleColor: "black"
            }
            Label {
                visible: authorLabel.visible
                fontSize: "small"
                opacity: 0.9
                horizontalAlignment: Text.AlignRight
                color: "white"
                width: parent.firstColWidth
                text: i18n.tr("Author:")
                style: Text.Raised
                styleColor: "black"
            }
            Label {
                id: authorLabel
                visible: text != ""
                fontSize: "small"
                opacity: 0.6
                color: "white"
                width: parent.secondColWidth
                text: nfo.ready ? nfo.video.author : ""
                wrapMode: Text.WordWrap
                style: Text.Raised
                styleColor: "black"
            }
        }

        Label {
            fontSize: "small"
            opacity: 0.6
            color: "white"
            text: {
                var parts = []
                if (nfo.ready) {
                    if (nfo.video.year) parts.push(nfo.video.year)
                    if (nfo.video.runtime) parts.push("%1 minutes".arg(nfo.video.runtime))
                }
                return parts.join(", ");
            }
            style: Text.Raised
            styleColor: "black"
        }
    }
}
