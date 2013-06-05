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

Rectangle {
    id: root
    property string title: ""
    property url url: ""
    property real previewWidthRatio: 0.5
    property bool playable: false
    property bool forceSquare: false
    property Component buttons
    property Component caption
    property Component description

    readonly property bool narrowMode: width <= height
    readonly property int contentSpacing: units.gu(3)

    signal close()
    signal previewImageClicked()

    color: Qt.rgba(0, 0, 0, .3)
    clip: true

    Connections {
        target: shell.applicationManager
        onMainStageFocusedApplicationChanged: {
            root.close();
        }
        onSideStageFocusedApplicationChanged: {
            root.close();
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    Item {
        id: headerRow
        height: units.gu(4)
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: root.contentSpacing
        }

        MouseArea {
            anchors {
                fill: parent
                leftMargin: -root.contentSpacing
                rightMargin: -root.contentSpacing
                topMargin: -root.contentSpacing
            }

            onClicked: root.close();
        }

        Item {
            id: labelItem
            anchors {
                fill: parent
                rightMargin: closePreviewImage.width + spacing
            }

            property int spacing: units.gu(2)

            Label {
                id: title
                objectName: "titleLabel"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                elide: Text.ElideRight
                fontSize: "x-large"
                font.weight: Font.Light
                color: "#f3f3e7"
                opacity: 0.9
                text: root.title
                style: Text.Raised
                styleColor: "black"
            }
            Image {
                id: closePreviewImage
                source: "graphics/tablet/icon_close_preview.png"
                width: units.gu(4)
                height: units.gu(1.5)
                anchors {
                    bottom: title.bottom
                    bottomMargin: units.dp(7)
                    left: parent.left
                    leftMargin: title.paintedWidth + labelItem.spacing
                }
            }
        }
    }

    Row {
        id: contentRow
        anchors {
            left: parent.left
            right: parent.right
            top: headerRow.bottom
            bottom: parent.bottom
            margins: root.contentSpacing
        }

        spacing: units.gu(2)

        Flickable {
            id: leftFlickable
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.narrowMode ? contentRow.width : contentRow.width * root.previewWidthRatio
            contentHeight: leftColumn.height
            clip: true

            Column {
                id: leftColumn
                objectName: "leftColumn"
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: childrenRect.height
                spacing: root.contentSpacing

                // TODO: replace this UbuntuShape with the Video component once that lands
                // with the player.
                UbuntuShape {
                    id: urlLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: root.forceSquare ? width : width * previewImage.sourceSize.height / previewImage.sourceSize.width
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
                Loader {
                    id: buttonLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    sourceComponent: root.buttons
                }
                Loader {
                    id: captionLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    sourceComponent: root.caption
                }
            }
        }

        Flickable {
            id: rightFlickable
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: narrowMode ? 0 : (contentRow.width - leftColumn.width - contentRow.spacing)
            contentHeight: rightColumn.height
            clip: true

            Column {
                id: rightColumn
                objectName: "rightColumn"
                height: childrenRect.height
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
        }
    }

    Loader {
        parent: root.narrowMode ? leftColumn : rightColumn
        anchors.left: parent.left
        anchors.right: parent.right
        sourceComponent: root.description
    }
}
