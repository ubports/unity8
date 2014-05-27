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
    signal enterDepartment(var departmentId, bool hasChildren)
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

    Flickable {
        id: flickable

        anchors.fill: parent

        readonly property int nItems: department && department.loaded ? (department.count + (department.parentId != "" ? 2 : 0)) : 0
        contentHeight: nItems * root.itemHeight
        contentWidth: width

        AbstractButton {
            id: backButton
            width: parent.width
            visible: department && department.parentId != ""
            height: itemHeight

            onClicked: root.goBackToParentClicked();

            Image {
                id: backImage
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                source: "image://theme/back"
                height: parent.height - units.gu(2)
                fillMode: Image.PreserveAspectFit
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: backImage.right
                text: department ? department.parentLabel : ""
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
            anchors.top: backButton.bottom
            width: parent.width
            visible: backButton.visible
            height: itemHeight

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: department ? department.allLabel : ""
                font.bold: true
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: units.gu(2)
                anchors.rightMargin: units.gu(2)
                width: parent.width
                color: "grey"
                opacity: 0.2
                height: units.dp(1)
            }

            onClicked: root.allDepartmentClicked();
        }
        // TODO Add line separator

        Repeater {
            model: department && department.loaded ? department : null
            clip: true
            delegate: AbstractButton {
                height: root.itemHeight
                width: root.width
                y: ((department.parentId != "" ? 2 : 0) + index) * root.itemHeight

                onClicked: root.enterDepartment(departmentId, hasChildren)

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: label
                }

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    source: "image://theme/chevron"
                    height: parent.height - units.gu(2)
                    fillMode: Image.PreserveAspectFit
                    visible: hasChildren
                }
                Text {
                    // TODO Be an image
                    text: "✓"
                    visible: !hasChildren && isActive
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter
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
