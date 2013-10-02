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

    Component {
        id: previewImageComponent
        LazyImage {
            anchors.left: parent.left
            anchors.right: parent.right
            scaleTo: "width"
            visible: height > 0
            source: root.url
            height: implicitHeight

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
            rating: Math.round(previewData.rating * 10)
            reviews: previewData.numRatings
            rated: previewData.infoMap["rated"] ? previewData.infoMap["rated"].value : 0
        }
    }
}
