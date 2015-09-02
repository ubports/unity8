/*
 * Copyright 2014-2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4

Rectangle {
    id: root
    color: "pink"

    implicitWidth: units.gu(40)
    implicitHeight: units.gu(70)

    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    property alias screenshotSource: screenshotImage.source
    property int orientationAngle

    Image {
        id: screenshotImage
        anchors.fill: parent
        fillMode: Image.Stretch
    }

    Text {
        text: surfaceText.text
        color: "black"
        font: surfaceText.font
        fontSizeMode: Text.Fit
        minimumPixelSize: 10
        verticalAlignment: Text.AlignVCenter
        rotation: surfaceText.rotation
        x: surfaceText.x
        y: surfaceText.y
        width: surfaceText.width
        height: surfaceText.height
        clip: true

        transform: Translate { x: -2; y: -2 }
    }
    Text {
        id: surfaceText
        text: "SURFACE " + root.width + "," + root.height
        color: root.parent && root.parent.activeFocus ? "yellow" : "blue"
        font.bold: true
        fontSizeMode: Text.Fit
        minimumPixelSize: 10; font.pixelSize: 200
        verticalAlignment: Text.AlignVCenter
        clip: true

        rotation: root.orientationAngle
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: (rotation == 0 || rotation == 180 ? parent.width : parent.height)
        height:(rotation == 0 || rotation == 180 ? parent.height : parent.width)
    }
}
