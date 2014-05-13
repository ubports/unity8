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
import "../"

/*! This preview widget shows a header
 *  The title comes in widgetData["title"]
 *  The mascot comes in widgetData["mascot"]
 *  The subtitle comes in widgetData["subtitle"]
 */

PreviewWidget {
    id: root

    height: childrenRect.height

    Item {
        id: headerRoot
        objectName: "innerPreviewHeader"
        readonly property url mascot: root.widgetData["mascot"] || ""
        readonly property string title: root.widgetData["title"] || ""
        readonly property string subtitle: root.widgetData["subtitle"] || ""
        readonly property color fontColor: "grey"

        implicitHeight: row.height + row.margins * 2
        width: parent.width

        Row {
            id: row
            objectName: "outerRow"

            property real margins: units.gu(1)

            spacing: mascotShapeLoader.active ? margins : 0
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                margins: margins
                leftMargin: spacing
                rightMargin: spacing
            }

            Loader {
                id: mascotShapeLoader

                anchors.verticalCenter: parent.verticalCenter
                // TODO karni: Icon aspect-ratio is 8:7.5. Revisit these values to avoid fraction of pixels.
                width: units.gu(6)
                height: units.gu(5.625)
                readonly property int maxSize: Math.max(width, height) * 4
                asynchronous: true

                sourceComponent: UbuntuShape {
                    objectName: "mascotShape"
                    visible: image.status === Image.Ready
                    image: Image {
                        source: headerRoot.mascot
                        width: source ? mascotShapeLoader.width : 0
                        height: mascotShapeLoader.height

                        sourceSize { width: mascotShapeLoader.maxSize; height: mascotShapeLoader.maxSize }
                        fillMode: Image.PreserveAspectCrop
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                    }
                }
            }

            Column {
                objectName: "column"
                width: parent.width - x
                spacing: units.dp(2)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    id: titleLabel
                    objectName: "titleLabel"
                    anchors { left: parent.left; right: parent.right }
                    elide: Text.ElideRight
                    font.weight: Font.Normal
                    fontSize: "large"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    color: headerRoot.fontColor
                    text: headerRoot.title
                }

                Loader {
                    active: titleLabel.text && headerRoot.subtitle
                    anchors { left: parent.left; right: parent.right }
                    sourceComponent: Label {
                        id: subtitleLabel
                        objectName: "subtitleLabel"
                        elide: Text.ElideRight
                        fontSize: "small"
                        font.weight: Font.Light
                        color: headerRoot.fontColor
                        text: headerRoot.subtitle
                    }
                }
            }
        }
    }

}
