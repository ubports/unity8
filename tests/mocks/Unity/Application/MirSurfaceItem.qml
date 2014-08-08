/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.0

Rectangle {
    id: root
    color: "yellow"

    property alias screenshotSource: screenshotImage.source

    property bool wantInputMethod: false

    Image {
        id: screenshotImage
        anchors.fill: parent
    }

    Text {
        anchors.fill: parent
        text: "SURFACE"
        color: "yellow"
        font.bold: true
        fontSizeMode: Text.Fit
        minimumPixelSize: 10; font.pixelSize: 200
        verticalAlignment: Text.AlignVCenter
    }

    MultiPointTouchArea {
        anchors.fill: parent
        onPressed: { root.wantInputMethod = true }
    }
}
