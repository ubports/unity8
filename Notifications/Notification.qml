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

UbuntuShape {
    id: notification

    property string type
    property alias iconSource: avatarIcon.source
    property alias secondaryIconSource: secondaryIcon.source
    property alias summary: summaryLabel.text
    property alias body: bodyLabel.text
    property var actions

    signal actionInvoked(string buttonId)

    implicitHeight: childrenRect.height
    color: Qt.rgba(0, 0, 0, 0.85)
    opacity: 0

    MouseArea {
        id: interactiveArea

        anchors.fill: contentColumn
        objectName: "interactiveArea"
        enabled: notification.type == "Notifications.Type.Interactive"
        onClicked: notification.actionInvoked(actions.get(0).id)
    }

    Column {
        id: contentColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: spacing
        }
        height: childrenRect.height + spacing
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
                    color: "#f3f3e7"
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
                    color: "#f3f3e7"
                    opacity: 0.6
                    wrapMode: Text.WordWrap
                    maximumLineCount: 10
                    elide: Text.ElideRight
                }
            }
        }

        Row {
            id: buttonRow

            objectName: "buttonRow"
            spacing: contentColumn.spacing
            layoutDirection: Qt.RightToLeft
            visible: notification.type == "Notifications.Type.SnapDecision"
            anchors {
                left: parent.left
                right: parent.right
            }

            Repeater {
                model: notification.actions

                Button {
                    objectName: "button" + index
                    color: Positioner.isFirstItem ? "#d85317" : "#cdcdcb"
                    width: (buttonRow.width - buttonRow.spacing) / 2
                    height: units.gu(4)
                    text: label
                    onClicked: notification.actionInvoked(id)
                }
            }
        }
    }
}
