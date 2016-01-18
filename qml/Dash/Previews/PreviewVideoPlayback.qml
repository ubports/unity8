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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Thumbnailer 0.1
import "../../Components"

/*! \brief Preview widget for video.

    This widget shows video contained in widgetData["source"],
    with a placeholder screenshot specified by widgetData["screenshot"].
 */

PreviewWidget {
    id: root
    implicitWidth: units.gu(35)
    implicitHeight: childrenRect.height

    widgetMargins: -units.gu(1)

    LazyImage {
        objectName: "screenshot"
        anchors {
            left: parent.left
            right: parent.right
        }
        scaleTo: "width"
        source: {
            var screenshot = widgetData["screenshot"];
            if (screenshot) return screenshot;

            var source = widgetData["source"];
            if (source) {
                if (source.toString().indexOf("file://") === 0) {
                    return "image://thumbnailer/" + source.toString().substr(7);
                }
            }

            return "";
        }
        initialHeight: width * 10 / 16
        useUbuntuShape: false

        Image {
            objectName: "playButton"

            readonly property bool bigButton: parent.width > units.gu(40)

            anchors.centerIn: parent
            width: bigButton ? units.gu(8) : units.gu(4.5)
            height: width
            source: "../graphics/play_button%1%2.png".arg(previewImageMouseArea.pressed ? "_active" : "").arg(bigButton ? "_big" : "")
            visible: parent.state === "ready"
        }

        MouseArea {
            enabled: parent.state === "ready"
            id: previewImageMouseArea
            anchors.fill: parent
            onClicked: Qt.openUrlExternally(widgetData["source"])
        }

        PreviewMediaToolbar {
            id: toolbar
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            shareData: widgetData["share-data"]
        }
    }
}
