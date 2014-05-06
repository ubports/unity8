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
    // TODO convert into enums when available in QML
    property string scaleTo

    property real initialWidth: scaleTo == "width" || scaleTo == "fit" ? width : units.gu(10)
    property real initialHeight: scaleTo == "height" || scaleTo == "fit" ? height : units.gu(10)

    property alias sourceSize: image.sourceSize
    property alias fillMode: image.fillMode
    property alias asynchronous: image.asynchronous
    property alias cache: image.cache
    property alias horizontalAlignment: image.horizontalAlignment
    property alias verticalAlignment: image.verticalAlignment
    property alias sourceImage: image

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
        anchors.fill: shape
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
        height: root.initialHeight
        width: root.initialWidth
        anchors.centerIn: root.scaleTo == "fit" ? parent : undefined

        opacity: 0
        visible: opacity != 0

        image: Image {
            id: image
            objectName: "image"

            property url nextSource
            property string format: image.implicitWidth > image.implicitHeight ? "landscape" : "portrait"

            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            sourceSize.width: root.scaleTo == "width" ? root.width
                                : root.scaleTo == "fit" && root.width <= root.height ? root.width
                                : 0
            sourceSize.height: root.scaleTo == "height" ? root.height
                                : root.scaleTo == "fit" && root.height <= root.width ? root.height
                                : 0
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
            PropertyChanges { target: root; implicitWidth: shape.width; implicitHeight: shape.height }
            PropertyChanges { target: placeholder; opacity: 0 }
            PropertyChanges { target: shape; opacity: 1
                width: root.scaleTo == "width" || (root.scaleTo == "fit" && image.format == "landscape") ? root.width
                    : root.scaleTo == "" ?  image.implicitWidth : image.implicitWidth * height / image.implicitHeight
                height: root.scaleTo == "height" || (root.scaleTo == "fit" && image.format == "portrait") ? root.height
                    : root.scaleTo == "" ? image.implicitHeight : image.implicitHeight * width / image.implicitWidth
            }
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
                    UbuntuNumberAnimation { target: shape; properties: "width,height" }
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
                    UbuntuNumberAnimation { target: shape; properties: "width,height" }
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
