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

    anchors.fill: parent

    Item {
        id: icon
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: styledItem.imageWidth
        height: styledItem.imageHeight

        Image {
            id: image
            objectName: "image"
            sourceSize { width: icon.width; height: icon.height }
            asynchronous: true
            cache: false
            source: styledItem.source
            fillMode: styledItem.fillMode
            horizontalAlignment: styledItem.horizontalAlignment
            verticalAlignment: styledItem.verticalAlignment
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

    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: icon.bottom
        }
        height: units.gu(2)

        Label {
            id: label
            objectName: "label"
            anchors {
                baseline: parent.bottom
                left: parent.left
                right: parent.right
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }

            color: Theme.palette.selected.backgroundText
            opacity: 0.9
            style: Text.Raised
            styleColor: "black"
            fontSize: "small"
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
            text: styledItem.text
        }
    }
}
