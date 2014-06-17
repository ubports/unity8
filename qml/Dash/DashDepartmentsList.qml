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
    signal enterDepartment(var newDepartmentId, bool hasChildren)
    signal goBackToParentClicked()
    signal allDepartmentClicked()

    readonly property int itemHeight: units.gu(5)
    implicitHeight: flickable.contentHeight

    Rectangle {
        color: "white"
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

        readonly property int nTopButtonsVisible: 0 + (backButton.visible ? 1 : 0) + (allButton.visible ? 1 : 0)
        readonly property int nItems: department && department.loaded ? (department.count + nTopButtonsVisible) : 0
        contentHeight: nItems * root.itemHeight
        contentWidth: width

        AbstractButton {
            id: backButton
            objectName: "backButton"
            width: parent.width
            visible: department && !department.isRoot || false
            height: visible ? itemHeight : 0

            onClicked: root.goBackToParentClicked();

            Image {
                id: backImage
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                source: "image://theme/back"
                sourceSize.height: parent.height - units.gu(2)
                sourceSize.width: units.gu(3)
                fillMode: Image.PreserveAspectFit
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: backImage.right
                text: department ? department.parentLabel : ""
                color: "gray" // TODO remove once we're a separate app
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: units.gu(2)
                anchors.rightMargin: units.gu(2)
                width: parent.width
                color: "gray"
                opacity: 0.2
                height: units.dp(1)
            }
        }

        AbstractButton {
            id: allButton
            objectName: "allButton"
            anchors.top: backButton.bottom
            width: parent.width
            visible: department && (!department.isRoot || (root.currentDepartment && !root.currentDepartment.isRoot && root.currentDepartment.parentDepartmentId == department.departmentId)) || false
            height: itemHeight

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: department ? (department.allLabel != "" ? department.allLabel : department.label) : ""
                font.bold: true
                color: "gray" // TODO remove once we're a separate app
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: units.gu(2)
                anchors.rightMargin: units.gu(2)
                width: parent.width
                color: "gray"
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
                y: (flickable.nTopButtonsVisible + index) * root.itemHeight

                onClicked: root.enterDepartment(departmentId, hasChildren)

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: label
                    color: "gray" // TODO remove once we're a separate app
                }

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    source: "image://theme/chevron"
                    sourceSize.height: parent.height - units.gu(2)
                    sourceSize.width: units.gu(3)
                    fillMode: Image.PreserveAspectFit
                    visible: hasChildren
                }
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    source: "graphics/tick.png"
                    sourceSize.height: parent.height - units.gu(2)
                    sourceSize.width: units.gu(3)
                    fillMode: Image.PreserveAspectFit
                    visible: !hasChildren && isActive
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(2)
                    anchors.rightMargin: units.gu(2)
                    width: parent.width
                    color: "gray"
                    opacity: 0.1
                    height: units.dp(1)
                    visible: index != department.count - 1
                }
            }
        }
    }
}
