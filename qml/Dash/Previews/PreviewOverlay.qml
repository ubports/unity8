/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import "../../Components"

Rectangle {
    id: overlay
    objectName: "overlay"

    readonly property real aspectRatio: width / height
    readonly property real initialAspectRatio: initialWidth / initialHeight
    readonly property real initialXScale: initialWidth / width
    readonly property real initialYScale: initialHeight / height

    property alias delegate: loader.sourceComponent
    property alias delegateItem: loader.item
    property alias headerShown: overlayHeader.shown
    property real initialX: 0
    property real initialY: 0
    property real initialWidth: 1
    property real initialHeight: 1

    property real xScale: initialXScale
    property real yScale: initialYScale
    property real progress: 0

    implicitWidth: 1
    implicitHeight: 1
    visible: progress > 0
    clip: progress > 0 && progress < 1
    color: Qt.rgba(0, 0, 0, progress)
    transformOrigin: Item.TopLeft
    transform: [
        Scale {
            origin.x: 0
            origin.y: 0
            xScale: overlay.xScale
            yScale: overlay.yScale
        },
        Translate {
            x: overlay.initialX - overlay.initialX * overlay.progress
            y: overlay.initialY - overlay.initialY * overlay.progress
        }
    ]
    state: "hidden"
    states: [
        State {
            name: "shown"
            PropertyChanges { target: overlay; progress: 1; xScale: 1; yScale: 1 }
        },
        State {
            name: "hidden"
            PropertyChanges { target: overlay; progress: 0; xScale: initialXScale; yScale: initialYScale }
        }
    ]
    transitions: [
        Transition {
            from: "hidden"
            to: "shown"
            UbuntuNumberAnimation {
                target: overlay
                properties: "progress,xScale,yScale"
                duration: UbuntuAnimation.FastDuration
            }
        },
        Transition {
            from: "shown"
            to: "hidden"
            UbuntuNumberAnimation {
                target: overlay
                properties: "progress,xScale,yScale"
                duration: UbuntuAnimation.FastDuration / 2
            }
        }
    ]

    function show() {
        state = "shown"
    }

    function hide() {
        state = "hidden"
    }

    Loader {
        id: loader
        anchors.fill: parent

        readonly property bool verticalScaling: initialAspectRatio / aspectRatio >= 1
        readonly property real initialXScale: verticalScaling ? 1 : aspectRatio / initialAspectRatio
        readonly property real initialYScale: verticalScaling ? initialAspectRatio / aspectRatio : 1
        readonly property real xScale: verticalScaling ? loader.initialXScale - loader.initialXScale * overlay.progress + overlay.progress :
                                                         loader.yScale * overlay.yScale / overlay.xScale
        readonly property real yScale: verticalScaling ? loader.xScale * overlay.xScale / overlay.yScale :
                                                         loader.initialYScale - loader.initialYScale * overlay.progress + overlay.progress

        transform: Scale {
            origin.x: parent.width / 2
            origin.y: parent.height / 2
            xScale: loader.xScale
            yScale: loader.yScale
        }
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
        opacity: overlay.state == "shown" && overlay.progress > 0.8 && shown ? 0.8 : 0
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
                color: theme.palette.normal.foregroundText
                name: "close"
            }
        }
    }
}
