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
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
*/

import QtQuick 2.0

Item {
    id: root

    signal clicked()

    property real topMarginProgress

    QtObject {
        id: priv
        property real heightDifference: root.height - appImage.implicitHeight
    }

    Image {
        id: dropShadow
        anchors.fill: appImage
        anchors.margins: -units.gu(2)
        source: "graphics/dropshadow.png"
        opacity: .4
    }
    Image {
        id: appImage
        anchors {
            left: parent.left;
            bottom: parent.bottom;
            top: parent.top;
            topMargin: priv.heightDifference * Math.max(0, 1 - root.topMarginProgress)
        }
        source: model.screenshot
        antialiasing: true
    }
    MouseArea {
        anchors.fill: appImage
        onClicked: root.clicked()
    }
}
