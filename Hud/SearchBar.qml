/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

Item {
    id: root
    property alias activityIndicatorVisible: activityIndicator.visible
    property alias text: searchBar.text
    property alias placeholderText: searchBar.placeholderText
    property alias searchEnabled: searchBar.enabled
    signal microphoneClicked
    signal textFocused

    readonly property real imageSize: units.gu(3)

    function unfocus()
    {
        searchBar.focus = false
    }

    ActivityIndicator {
        id: activityIndicator
        height: imageSize
        width: height
        x: magnifierImage.x
        y: magnifierImage.y
        running: visible
    }

    TextField {
        id: searchBar
        anchors.fill: parent

        hasClearButton: false
        font.pixelSize: FontUtils.sizeToPixels("large")

        onActiveFocusChanged: {
            if (activeFocus) {
                root.textFocused()
            }
        }

        Item {
            id: primary
            height: searchBar.height
            width: height

            Image {
                id: magnifierImage
                height: imageSize
                width: height
                anchors.centerIn: parent
                source: "graphics/icon_search.png"
                visible: !activityIndicator.visible && !clearImage.visible
            }

            Image {
                id: clearImage
                height: imageSize
                width: height
                anchors.centerIn: parent
                source: "graphics/icon_clear.png"
                visible: !activityIndicator.visible && searchBar.text != ""
                MouseArea {
                    anchors.fill: parent
                    onClicked: searchBar.text = ""
                }
            }
        }

        primaryItem: primary
        secondaryItem: MouseArea {
            height: searchBar.height
            width: height
            onClicked: microphoneClicked()

            Image {
                height: imageSize
                width: height
                anchors.centerIn: parent
                source: "graphics/microphone.png"
            }
        }
    }
}
