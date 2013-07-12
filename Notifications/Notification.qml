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
import Unity.Notifications 1.0

UbuntuShape {
    id: notification

    property alias iconSource: avatarIcon.source
    property alias secondaryIconSource: secondaryIcon.source
    property alias summary: summaryLabel.text
    property alias body: bodyLabel.text
    property var actions
    property var notificationId
    property var type
    property var notification

    objectName: "background"
    implicitHeight: contentColumn.height + contentColumn.spacing * 2
    color: Qt.rgba(0, 0, 0, 0.85)
    opacity: 0

    clip: true

    Behavior on implicitHeight {
        id: heightBehavior

        enabled: false
        UbuntuNumberAnimation {
            duration: UbuntuAnimation.SnapDuration
        }
    }

    // delay enabling height behavior until the add transition is complete
    onOpacityChanged: if (opacity == 1) heightBehavior.enabled = true

    MouseArea {
        id: interactiveArea

        anchors.fill: contentColumn
        objectName: "interactiveArea"
        enabled: notification.type == Notification.Interactive
        onClicked: notification.notification.invokeAction(actionRepeater.itemAt(0).actionId)
    }

    Column {
        id: contentColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: spacing
        }

        spacing: units.gu(1)

        Row {
            id: topRow

            spacing: contentColumn.spacing
            anchors {
                left: parent.left
                right: parent.right
            }

            UbuntuShape {
                id: icon

                objectName: "icon"
                width: units.gu(6)
                height: units.gu(6)
                visible: iconSource !== undefined && iconSource != ""
                image: Image {
                    id: avatarIcon

                    fillMode: Image.PreserveAspectCrop
                }
            }

            Image {
                id: secondaryIcon

                objectName: "secondaryIcon"
                width: units.gu(2)
                height: units.gu(2)
                visible: source !== undefined && source != ""
                fillMode: Image.PreserveAspectCrop
            }

            Column {
                id: labelColumn
                width: parent.width - x

                Label {
                    id: summaryLabel

                    objectName: "summaryLabel"
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    fontSize: "medium"
                    font.bold: true
                    color: Theme.palette.selected.backgroundText
                    elide: Text.ElideRight
                }

                Label {
                    id: bodyLabel

                    objectName: "bodyLabel"
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    visible: body != ""
                    fontSize: "small"
//                    color: Theme.palette.selected.backgroundText
                    opacity: 0.6
                    wrapMode: Text.WordWrap
                    maximumLineCount: 10
                    elide: Text.ElideRight
                }
            }
        }

        Item {
            id: buttonRow

            objectName: "buttonRow"
            anchors {
                left: parent.left
                right: parent.right
            }
            visible: notification.type == Notification.SnapDecision
            height: units.gu(4)

            property real buttonWidth: (width - contentColumn.spacing) / 2
            property bool expanded

            Button {
                id: leftButton

                objectName: "button1"
                width: parent.expanded ? parent.width : parent.buttonWidth
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                text: notification.type == Notification.SnapDecision && actionRepeater.count >= 2 ? actionRepeater.itemAt(1).actionLabel : ""
                color: "#cdcdcb"
                onClicked: {
                    if (actionRepeater.count > 2) {
                        buttonRow.expanded = !buttonRow.expanded
                    } else {
                        notification.notification.invokeAction(actionRepeater.itemAt(1).actionId)
                    }
                }

                Behavior on width {
                    UbuntuNumberAnimation {
                        duration: UbuntuAnimation.SnapDuration
                    }
                }
            }

            Button {
                id: rightButton

                objectName: "button0"
                anchors {
                    left: leftButton.right
                    leftMargin: contentColumn.spacing
                    right: parent.right
                }
                text: notification.type == Notification.SnapDecision && actionRepeater.count >= 1 ? actionRepeater.itemAt(0).actionLabel : ""
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: "#d85317" // FIXME ??
                visible: width > 0
                onClicked: notification.notification.invokeAction(actionRepeater.itemAt(0).actionId)
            }
        }

        Column {
            objectName: "buttonColumn"
            spacing: contentColumn.spacing
            anchors {
                left: parent.left
                right: parent.right
            }

            // calculate initial position before Column takes over
            y: buttonRow.y + buttonRow.height + contentColumn.spacing

            visible: notification.type == Notification.SnapDecision
            height: buttonRow.expanded ? implicitHeight : 0

            Repeater {
                id: actionRepeater

                model: notification.actions
                delegate: Loader {
                    id: loader

                    property string actionId: id
                    property string actionLabel: label

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    Component {
                        id: actionButton

                        Button {
                            objectName: "button" + index
                            anchors {
                                left: parent.left
                                right: parent.right
                            }

                            text: loader.actionLabel
                            height: units.gu(4)
                            color: "#cdcdcb" // FIXME ?? which color?
                            onClicked: notification.notification.invokeAction(loader.actionId)
                        }
                    }
                    sourceComponent: (index == 0 || index == 1) ? undefined : actionButton
                }
            }
        }
    }
}
