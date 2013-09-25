/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *   Michał Sawicz <michal.sawicz@canonical.com>
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

    property url source

    property real initialWidth: sourceSize.width > -1 ? sourceSize.width : units.gu(10)
    property real initialHeight: sourceSize.height > -1 ? sourceSize.height : units.gu(10)
    property size sourceSize

    property alias fillMode: image.fillMode
    property alias asynchronous: image.asynchronous
    property alias cache: image.cache
    property alias horizontalAlignment: image.horizontalAlignment
    property alias verticalAlignment: image.verticalAlignment

    state: "default"

    onSourceChanged: {
        if (state === "ready") {
            state = "default";
            image.nextSource = source;
        } else {
            image.source = source;
        }
    }

    UbuntuShape {
        id: placeholder
        objectName: "placeholder"
        color: "#22FFFFFF"
        anchors.fill: parent
        visible: opacity != 0

        ActivityIndicator {
            id: activity
            anchors.centerIn: parent
            opacity: 0
            visible: opacity != 0

            running: visible
        }

        Image {
            id: errorImage
            objectName: "errorImage"
            anchors.centerIn: parent
            opacity: 0
            visible: opacity != 0

            source: "graphics/close.png"
            sourceSize { width: units.gu(3); height: units.gu(3) }
        }
    }

    UbuntuShape {
        id: shape
        objectName: "shape"
        anchors.fill: parent
        opacity: 0
        visible: opacity != 0

        image: Image {
            id: image
            objectName: "image"

            property url nextSource

            width: {
                if (root.sourceSize.width > -1) return root.sourceSize.width;
                if (root.sourceSize.height > -1) return implicitWidth * root.sourceSize.height / implicitHeight
                return implicitWidth
            }
            height: {
                if (root.sourceSize.height > -1) return root.sourceSize.height;
                if (root.sourceSize.width > -1) return implicitHeight* root.sourceSize.width / implicitWidth
                return implicitHeight
            }
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            sourceSize.width: root.sourceSize.width
            sourceSize.height: root.sourceSize.height
        }
    }

    states: [
        State {
            name: "default"
            when: image.source == ""
            PropertyChanges { target: root; implicitWidth: root.initialWidth; implicitHeight: root.initialHeight }
            PropertyChanges { target: errorImage; opacity: 0 }
        },
        State {
            name: "loading"
            extend: "default"
            when: image.status === Image.Loading
            PropertyChanges { target: activity; opacity: 1 }
        },
        State {
            name: "ready"
            when: image.status === Image.Ready && image.source != ""
            PropertyChanges { target: root; implicitWidth: image.width; implicitHeight: image.height }
            PropertyChanges { target: shape; opacity: 1 }
            PropertyChanges { target: placeholder; opacity: 0 }
        },
        State {
            name: "error"
            extend: "default"
            when: image.status === Image.Error
            PropertyChanges { target: errorImage; opacity: 1.0 }
        }
    ]

    transitions: [
        Transition {
            to: "ready"
            objectName: "readyTransition"
            SequentialAnimation {
                PropertyAction { target: shape; property: "visible" }
                ParallelAnimation {
                    NumberAnimation { target: shape; property: "opacity"; easing.type: Easing.Linear }
                    UbuntuNumberAnimation { target: root; properties: "implicitWidth,implicitHeight" }
                    NumberAnimation {
                        targets: [placeholder, activity, errorImage]; property: "opacity";
                        easing.type: Easing.Linear; duration: UbuntuAnimation.SnapDuration
                    }
                }
            }
        },

        Transition {
            to: "*"
            objectName: "genericTransition"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: shape; property: "opacity"; easing.type: Easing.Linear }
                    NumberAnimation {
                        targets: [placeholder, activity, errorImage]; property: "opacity";
                        easing.type: Easing.Linear; duration: UbuntuAnimation.SnapDuration
                    }
                    UbuntuNumberAnimation { target: root; properties: "implicitWidth,implicitHeight" }
                }
                PropertyAction { target: shape; property: "visible" }
            }

            onRunningChanged: {
                if (!running && state === "default" && image.nextSource !== "") {
                    image.source = image.nextSource;
                    image.nextSource = "";
                }
            }
        }
    ]
}
