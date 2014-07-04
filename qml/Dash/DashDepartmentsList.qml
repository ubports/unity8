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

import QtQuick 2.2
import Ubuntu.Components 0.1

Item {
    id: root
    property var department: null
    property var currentDepartment: null
    property color foregroundColor: "gray"
    property color backgroundColor: "white"
    signal enterDepartment(var newDepartmentId, bool hasChildren)
    signal goBackToParentClicked()
    signal allDepartmentClicked()

    readonly property int itemHeight: units.gu(5)
    implicitHeight: flickable.contentHeight


    Rectangle {
        color: root.backgroundColor
        anchors.fill: parent
    }

    ActivityIndicator {
        id: loadingIndicator
        anchors.centerIn: parent
        running: !(department && department.loaded)
    }
    clip: true

    Behavior on height {
        UbuntuNumberAnimation {
            id: heightAnimation
            duration: UbuntuAnimation.SnapDuration
        }
    }

    Flickable {
        id: flickable

        anchors.fill: parent

        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width

            // TODO: check if SDK ListItems could be used here
            // and if not make them be useful since this is a quite common pattern

            AbstractButton {
                id: backButton
                objectName: "backButton"
                width: parent.width
                visible: department && !department.isRoot || false
                height: itemHeight

                onClicked: root.goBackToParentClicked();

                Icon {
                    id: backImage
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    name: "back"
                    height: units.gu(2)
                    width: height
                    color: root.foregroundColor
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: backImage.right
                        leftMargin: units.gu(0.5)
                    }
                    text: department ? department.parentLabel : ""
                    color: root.foregroundColor
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(2)
                        rightMargin: units.gu(2)
                    }
                    color: root.foregroundColor
                    opacity: 0.2
                    height: units.dp(1)
                }
            }

            AbstractButton {
                id: allButton
                objectName: "allButton"
                width: parent.width
                visible: department && (!department.isRoot || (root.currentDepartment && !root.currentDepartment.isRoot && root.currentDepartment.parentDepartmentId == department.departmentId)) || false
                height: itemHeight

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    text: department ? (department.allLabel != "" ? department.allLabel : department.label) : ""
                    font.bold: true
                    color: root.foregroundColor
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(2)
                        rightMargin: units.gu(2)
                    }
                    color: root.foregroundColor
                    opacity: 0.2
                    height: units.dp(1)
                }

                onClicked: root.allDepartmentClicked();
            }

            Repeater {
                model: department && department.loaded ? department : null
                clip: true
                delegate: AbstractButton {
                    objectName: root.objectName + "child" + index
                    height: root.itemHeight
                    width: root.width

                    onClicked: root.enterDepartment(departmentId, hasChildren)

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: units.gu(2)
                        }
                        text: label
                        color: root.foregroundColor
                    }

                    Icon {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(2)
                        }
                        height: units.gu(2)
                        width: height
                        name: hasChildren ? "go-next" : "tick"
                        color: root.foregroundColor
                        visible: hasChildren || isActive
                    }

                    Rectangle {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            leftMargin: units.gu(2)
                            rightMargin: units.gu(2)
                        }
                        color: root.foregroundColor
                        opacity: 0.1
                        height: units.dp(1)
                        visible: index != department.count - 1
                    }
                }
            }
        }
    }
}
