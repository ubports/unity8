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

Item {
    id: tile

    property alias artist: artistLabel.text

    anchors.fill: parent

    UbuntuShape {
        id: icon
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        radius: "medium"
        width: styledItem.imageWidth
        height: styledItem.imageHeight
        image: Image {
            id: image
            objectName: "image"
            sourceSize { width: icon.width; height: icon.height }
            asynchronous: true
            cache: false
            source: styledItem.source
            fillMode: styledItem.fillMode
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }
    }

    UbuntuShape {
        id: borderPressed
        objectName: "borderPressed"

        anchors.fill: icon
        radius: "medium"
        borderSource: "radius_pressed.sci"
        opacity: styledItem.pressed ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }
    }

    Label {
        id: label
        objectName: "label"
        anchors {
            baseline: icon.bottom
            baselineOffset: units.gu(2)
            left: icon.left
            right: parent.right
            rightMargin: units.gu(1)
            leftMargin: units.dp(2)
        }

        color: Theme.palette.selected.backgroundText
        opacity: 0.9
        style: Text.Raised
        styleColor: "black"
        fontSize: "small"
        font.weight: Font.Bold
        elide: Text.ElideRight
        horizontalAlignment: styledItem.horizontalAlignment
        text: styledItem.text
        wrapMode: Text.Wrap
        maximumLineCount: styledItem.maximumLineCount
    }

    Label {
        id: artistLabel
        anchors {
            top: label.bottom
            left: label.left
            right: label.right
            rightMargin: units.gu(1)
        }

        color: Theme.palette.selected.backgroundText
        opacity: 0.9
        style: Text.Raised
        styleColor: "black"
        fontSize: "x-small"
        elide: Text.ElideMiddle
        horizontalAlignment: styledItem.horizontalAlignment
    }
}
