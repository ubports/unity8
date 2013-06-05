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
import "../../Components"

BaseCarouselDelegate {
    id: item

    property var dataModel
    readonly property real frameHeight: Math.max(height / 3.6, units.gu(5.5))

    UbuntuShape {
        anchors.fill: parent
        radius: "medium"
        borderSource: ""
        image: Image {
            asynchronous: true
            sourceSize { width: item.width; height: item.height }
            source: dataModel.avatar ? dataModel.avatar : ""
            fillMode: Image.PreserveAspectCrop
        }
    }

    Component {
        id: component_frame
        Item {
            id: frame

            BorderImage {
                // TODO This will go away once we have 'clip: true' in UbuntuShape
                anchors.centerIn: parent
                width: parent.width + units.gu(1.5)
                height: parent.height + units.gu(1.5)
                visible: labelRemotePost.visible
                opacity: 0.9
                source: "graphics/bottomshape.sci"
            }

            property bool showRemoteDetails: true
            // To decide if the remote icon and time should be shown, its once layed out to do so.
            // Then it's checked if everything fits in the frame size. If not, showRemoteDetails is set false
            // Using bindings to do so cause a binding loop
            function checkSizeForRemoteDetails() {
                showRemoteDetails = true
                showRemoteDetails = (frame.height - column.minimumHeight) >= labelRemotePostTime.height
            }

            Item {
                id: remoteSourceIconContainer

                // TODO use proper asset and get rid of these dimensions
                width: units.gu(3)
                height: units.gu(4)
                visible: showRemoteDetails

                Image {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: units.gu(1)
                    source: dataModel.remoteSourceIcon ? dataModel.remoteSourceIcon : ""
                    fillMode: Image.PreserveAspectFit
                }
            }

            Column {
                id: column

                property real minimumHeight: labelName.height + labelRemotePost.height + anchors.topMargin + anchors.bottomMargin

                anchors {
                    left: remoteSourceIconContainer.visible ? remoteSourceIconContainer.right : parent.left
                    right: parent.right
                    top: remoteSourceIconContainer.visible ? parent.top : undefined
                    verticalCenter: remoteSourceIconContainer.visible ? undefined : parent.verticalCenter
                    margins: units.gu(1)
                }

                Label {
                    id: labelName

                    width: parent.width
                    text: dataModel.name ? dataModel.name : ""
                    color: "white"
                    fontSize: "x-small"
                    elide: Text.ElideRight
                    font.weight: Font.Bold
                    onTextChanged: checkSizeForRemoteDetails()
                }

                Label {
                    id: labelRemotePost

                    width: parent.width
                    text: dataModel.remotePost ? dataModel.remotePost : ""
                    color: "white"
                    opacity: 0.8
                    fontSize: "xx-small"
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    onTextChanged: checkSizeForRemoteDetails()
                }

                Label {
                    id: labelRemotePostTime

                    width: parent.width
                    text: model.remotePostTime ? model.remotePostTime : ""
                    color: "white"
                    opacity: 0.5
                    fontSize: "xx-small"
                    elide: Text.ElideRight
                    visible: showRemoteDetails
                    onTextChanged: checkSizeForRemoteDetails()
                }
            }

            onHeightChanged: checkSizeForRemoteDetails()
            onWidthChanged: checkSizeForRemoteDetails()
            Component.onCompleted: checkSizeForRemoteDetails()
        }
    }

    Loader {
        id: loader_frame

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: item.frameHeight
        opacity: item.explicitlyScaled ? 1.0 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        sourceComponent: opacity > 0 ? component_frame : undefined
    }

    BorderImage {
        anchors.centerIn: parent
        opacity: 0.6
        source: "../../Components/graphics/non-selected.sci"
        width: parent.width + units.gu(1.5)
        height: parent.height + units.gu(1.5)
    }
}
