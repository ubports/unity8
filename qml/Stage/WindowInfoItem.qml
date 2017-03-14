/*
 * Copyright (C) 2017 Canonical, Ltd.
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

Item {
    id: root
    implicitWidth: Math.max(iconShape.width, titleLabel.width)
    implicitHeight: iconShape.height + titleLabel.height + labelMargin + iconMargin
    property alias title: titleLabel.text
    property alias iconSource: icon.source

    property real iconHeight: (height - titleLabel.height) * 0.65
    property real iconMargin: (height - titleLabel.height) * 0.25
    property real labelMargin: (height - titleLabel.height) * 0.1
    property int maxWidth: units.gu(10)

    signal clicked()

    ProportionalShape {
        id: iconShape
        anchors {
            top: parent.top
            topMargin: iconMargin
            left: parent.left
        }
        height: iconHeight
        borderSource: "undefined"
        aspect: UbuntuShape.Flat
        source: Image {
            id: icon
            sourceSize.width: iconShape.width
            sourceSize.height: iconShape.height
            cache: false // see lpbug#1543290 why no cache
        }
    }

    MouseArea {
        anchors.fill: iconShape
        onClicked: root.clicked()
    }

    Label {
        id: titleLabel
        anchors {
            left: iconShape.left
            top: iconShape.bottom
            topMargin: labelMargin
        }
        width: root.maxWidth
        fontSize: 'small'
        color: 'white'
        elide: Label.ElideRight
    }
}
