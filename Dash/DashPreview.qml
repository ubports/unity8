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

    property int keyboardSize: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
    property var previewData

    property string title: ""
    property real previewWidthRatio: 0.5

    property Component header
    property Component buttons
    property Component body

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
                color: Theme.palette.selected.backgroundText
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
            objectName: "leftFlickable"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.narrowMode ? contentRow.width : contentRow.width * root.previewWidthRatio
            contentHeight: leftColumn.height
            anchors.bottomMargin: root.keyboardSize
            clip: true

            Column {
                id: leftColumn
                objectName: "leftColumn"
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: childrenRect.height
                spacing: units.gu(1)

                Loader {
                    id: headerLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    sourceComponent: root.header
                }
                Loader {
                    id: buttonLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    sourceComponent: root.buttons
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
        sourceComponent: root.body
    }
}
