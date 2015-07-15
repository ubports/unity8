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

Item {
    id: root

    // Whether this slider is short or long
    property bool shortSwipe

    // How far the user has slid
    property real offset

    // Set to true when slider is being used
    property bool active

    // How far in percentage terms
    readonly property real percent: d.slideOffset / target.x

    QtObject {
        id: d
        readonly property color trayColor: "#424141"
        readonly property real margin: units.gu(0.5)
        readonly property real arrowSize: root.height - margin * 2
        readonly property real dotSize: units.dp(1)
        readonly property real slideOffset: MathUtils.clamp(root.offset - offscreenOffset, -offscreenOffset, target.x)
        readonly property real offscreenOffset: units.gu(2)
    }

    implicitWidth: shortSwipe ? units.gu(15) : units.gu(27.5)
    implicitHeight: units.gu(6.5)

    Rectangle {
        color: d.trayColor
        anchors.fill: parent
        anchors.rightMargin: clipBox.width - 1
    }

    // We want to have a circular border around the target.  But we can't just
    // do a radius on two of a rectangle's corners.  So we clip a full circle.
    Item {
        id: clipBox

        clip: true
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.height / 2

        Rectangle {
            color: d.trayColor
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.width * 2
            radius: parent.width
        }
    }

    Arrow {
        id: target
        width: d.arrowSize
        height: d.arrowSize
        color: "#73000000"
        chevronOpacity: 0.52
        anchors.right: parent.right
        anchors.rightMargin: d.margin
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        anchors.left: handle.horizontalCenter
        anchors.right: target.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        layoutDirection: Qt.RightToLeft
        spacing: d.dotSize * 2

        Repeater {
            model: parent.width / (parent.spacing + d.dotSize)
            Rectangle {
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                height: d.dotSize
                width: height
                radius: width
                color: "white"
                opacity: 0.2
            }
        }
    }

    Arrow {
        id: handle
        width: d.arrowSize
        height: d.arrowSize
        color: UbuntuColors.orange
        darkenBy: root.active ? 0.5 : 0
        anchors.left: parent.left
        // We use a Translate transform rather than anchors.leftMargin because
        // the latter has weird performance problems on the TutorialRight page.
        transform: [
            Translate {
                x: d.slideOffset
            }
        ]
        anchors.verticalCenter: parent.verticalCenter
    }
}
