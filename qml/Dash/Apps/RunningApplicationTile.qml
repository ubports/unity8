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
import Mir.Application 0.1
import "../../Components/"
import "../../Components/ListItems"

AbstractButton {
    id: root
    property var application

    signal requestedApplicationActivation(var application)
    signal requestedApplicationTermination(var application)
    signal requestedActivationMode()
    signal requestedTerminationMode()

    width: thumbnail.width
    height: thumbnail.height + labelContainer.height

    // Orientation angle of the Shell UI, relative to the scene (QQuickView's) root item.
    property int orientationAngle

    property bool terminationModeEnabled: false

    onClicked: {
        if (!terminationModeEnabled)
            requestedApplicationActivation(application)
    }

    onPressAndHold: {
        if (terminationModeEnabled) {
            requestedActivationMode()
        } else {
            requestedTerminationMode()
        }
    }

    Item {
        id: thumbnail

        width: thumbnailHelper.flippedDimensions ? shapedApplicationImage.height : shapedApplicationImage.width
        height: thumbnailHelper.flippedDimensions ? shapedApplicationImage.width : shapedApplicationImage.height

        onWidthChanged: {console.log("thumbnail.width = " + width);}
        onHeightChanged: {console.log("thumbnail.height = " + height);}


        Item {
            id: thumbnailHelper

            property bool flippedDimensions: root.orientationAngle == 90 || root.orientationAngle == 270

            // Compensate for the UI rotation that is done by the application itself
            // TODO: Only counter-rotate if the application UI is rotated in the first place
            //       Currently we don't have this info, so we just assume every single app rotate
            //       its UI
            transformOrigin: Item.TopLeft
            state: orientationAngle.toString()
            states: [
                State {
                    name: "0"
                    PropertyChanges {
                        target: thumbnailHelper
                        rotation: 0
                        x: 0
                        y: 0
                    }
                },
                State {
                    name: "90"
                    PropertyChanges {
                        target: thumbnailHelper
                        rotation: -90
                        x: 0
                        y: shapedApplicationImage.width
                    }
                },
                State {
                    name: "180"
                    PropertyChanges {
                        target: thumbnailHelper
                        rotation: -180
                        x: shapedApplicationImage.width
                        y: shapedApplicationImage.height
                    }
                },
                State {
                    name: "270"
                    PropertyChanges {
                        target: thumbnailHelper
                        rotation: -270
                        x: shapedApplicationImage.height
                        y: 0
                    }
                }
            ]

            UbuntuShape {
                id: shapedApplicationImage
                x: 0
                y: 0
                height: applicationImage.height
                width: applicationImage.width
                radius: "medium"

                image: Image {
                    id: applicationImage
                    source: application.screenshot
                    // height : width = ss.height : ss.width
                    height: units.gu(17)
                    fillMode: Image.PreserveAspectCrop
                    width: Math.min(height, height * sourceSize.width / sourceSize.height)
                }

            }

            UbuntuShape {
                id: borderPressed

                anchors.fill: shapedApplicationImage
                radius: "medium"
                borderSource: "radius_pressed.sci"
                opacity: root.pressed ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }
            }
        }
    }

    // FIXME: label code duplicated with Tile
    Item {
        id: labelContainer
        anchors {
            left: thumbnail.left
            right: thumbnail.right
            top: thumbnail.bottom
        }
        height: units.gu(2)

        Label {
            id: label
            anchors {
                baseline: parent.bottom
                left: parent.left
                right: parent.right
            }
            text: (application) ? application.name : ""

            // TODO karni: Update Ubuntu.Components.Themes.Palette and use theme color instead
            color: "grey"
            opacity: 0.9
            fontSize: "small"
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
        }
    }

    CloseIcon {
        objectName: "closeIcon " + model.name
        anchors {
            left: thumbnail.left
            leftMargin: -units.gu(1)
            top: thumbnail.top
            topMargin: -units.gu(1)
        }
        height: units.gu(6)
        width: units.gu(6)
        id: closeIcon
        enabled: root.terminationModeEnabled

        MouseArea {
            anchors { fill: parent; margins: -units.gu(1) }
            onClicked: requestedApplicationTermination(application)
        }
    }
}
