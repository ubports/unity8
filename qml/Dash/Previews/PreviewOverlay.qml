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

import QtQuick 2.0
import Ubuntu.Components 1.1
import "../../Components"

Rectangle {
    id: overlay
    objectName: "overlay"

    readonly property real scaleProgress: (scale - initialScale) / (1.0 - initialScale)

    property alias delegate: loader.sourceComponent
    property alias delegateItem: loader.item
    property alias headerShown: overlayHeader.shown
    property bool shown: false
    property bool opening: false
    property real initialX: 0
    property real initialY: 0
    property real initialScale: 0

    visible: scale > initialScale
    clip: visible && scale < 1.0
    scale: shown ? 1.0 : initialScale
    transformOrigin: Item.TopLeft
    transform: Translate {
        x: overlay.initialX - overlay.initialX * overlay.scaleProgress
        y: overlay.initialY - overlay.initialY * overlay.scaleProgress
    }
    color: Qt.rgba(0, 0, 0, scaleProgress)
    radius: units.gu(1) - units.gu(1) * scaleProgress

    function show() {
        opening = true;
        shown = true;
    }

    function hide() {
        opening = false;
        shown = false;
    }

    Behavior on scale {
        UbuntuNumberAnimation {
            duration: overlay.opening ? UbuntuAnimation.FastDuration :
                                        UbuntuAnimation.FastDuration / 2
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Rectangle {
        id: overlayHeader

        property bool shown: true

        anchors {
            left: parent.left
            right: parent.right
        }
        height: units.gu(7)
        visible: opacity > 0
        opacity: overlay.scaleProgress > 0.6 && shown ? 0.8 : 0
        color: "black"

        Behavior on opacity {
            UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
        }

        AbstractButton {
            id: overlayCloseButton
            objectName: "overlayCloseButton"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(8)
            height: width

            onClicked: overlay.hide()

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(1.0, 1.0, 1.0, 0.3)
                visible: overlayCloseButton.pressed
            }

            Icon {
                id: icon
                anchors.centerIn: parent
                width: units.gu(2.5)
                height: width
                color: Theme.palette.normal.foregroundText
                name: "close"
            }
        }
    }
}
