/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

Item {
    id: root

    property alias component: loader.sourceComponent

    signal actionClicked(string action)
    signal viewModeClicked

    property list<Action> userActions
    property Action viewAction

    property color iconColor
    property color backgroundColor

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: units.gu(2)
        }
        spacing: units.gu(2)

        AbstractButton {
            id: actionButton
            Layout.preferredWidth: units.gu(3)
            Layout.preferredHeight: units.gu(3)
            Layout.alignment: Qt.AlignVCenter
            enabled: action && action.enabled

            Action {
                id: popupAction
                iconName: "navigation-menu"
                onTriggered: userActionsPopup.createObject(root, { "anchors.bottom": root.top })
            }

            action: {
                switch (userActions.length) {
                    case 0:
                        return null;
                    case 1:
                        return userActions[0];
                    default:
                        return popupAction;
                }
            }

            Icon {
                anchors.fill: parent
                visible: actionButton.action && actionButton.action.iconSource !== "" || false
                source: actionButton.action ? actionButton.action.iconSource : ""
                color: root.iconColor
                opacity: actionButton.action && actionButton.action.enabled ? 1.0 : 0.5
            }
        }

        Loader {
            id: loader
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(3)
        }

        AbstractButton {
            objectName: "viewActionButton"
            Layout.preferredWidth: units.gu(3)
            Layout.preferredHeight: units.gu(3)
            Layout.alignment: Qt.AlignVCenter
            enabled: viewAction.enabled
            action: viewAction

            Icon {
                anchors.fill: parent
                visible: viewAction.iconSource !== ""
                source: viewAction.iconSource
                color: root.iconColor
                opacity: viewAction.enabled ? 1.0 : 0.5
            }
        }
    }

    Component {
        id: userActionsPopup

        Rectangle {
            id: popup
            color: root.backgroundColor
            width: userActionsColumn.width
            height: userActionsColumn.height

            InverseMouseArea {
                id: eventGrabber
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                anchors.fill: popup
                propagateComposedEvents: false
                onWheel: wheel.accepted = true

                onPressed: popup.destroy()
            }

            Column {
                id: userActionsColumn
                spacing: units.gu(1)
                width: units.gu(31)

                Repeater {
                    id: actionRepeater
                    model: userActions
                    AbstractButton {
                        action: modelData

                        onClicked: popup.destroy()

                        implicitHeight: units.gu(4) + bottomDividerLine.height
                        width: parent ? parent.width : units.gu(31)

                        Rectangle {
                            visible: parent.pressed
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }
                            height: parent.height - bottomDividerLine.height
                            opacity: 0.5
                        }

                        Icon {
                            id: actionIcon
                            visible: "" !== action.iconSource
                            source: action.iconSource
                            color: root.iconColor
                            anchors {
                                verticalCenter: parent.verticalCenter
                                verticalCenterOffset: units.dp(-1)
                                left: parent.left
                                leftMargin: units.gu(2)
                            }
                            width: units.gu(2)
                            height: units.gu(2)
                            opacity: action.enabled ? 1.0 : 0.5
                        }

                        Label {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                verticalCenterOffset: units.dp(-1)
                                left: actionIcon.visible ? actionIcon.right : parent.left
                                leftMargin: units.gu(2)
                                right: parent.right
                            }
                            // In the tabs overflow panel there are no icons, and the font-size
                            //  is medium as opposed to the small font-size in the actions overflow panel.
                            fontSize: actionIcon.visible ? "small" : "medium"
                            elide: Text.ElideRight
                            text: action.text
                            color: root.iconColor
                            opacity: action.enabled ? 1.0 : 0.5
                        }

                        ListItem.ThinDivider {
                            id: bottomDividerLine
                            anchors.bottom: parent.bottom
                            visible: index !== actionRepeater.count - 1
                        }
                    }
                }
            }
        }
    }
}
