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

AbstractButton {
    id: root
    objectName: "dashDepartments"

    property var scope: null

    property bool showList: false

    readonly property var currentDepartment: scope && scope.hasDepartments ? scope.getDepartment(scope.currentDepartmentId) : null

    property alias windowWidth: blackRect.width
    property alias windowHeight: blackRect.height

    // Are we drilling down the tree or up?
    property bool isGoingBack: false

    visible: root.currentDepartment != null

    height: visible ? units.gu(5) : 0

    onClicked: {
        root.showList = !root.showList;
    }

    Rectangle {
        id: blackRect
        color: "black"
        opacity: 0.3
        anchors.top: departmentListView.top
        anchors.right: parent.right
        visible: departmentListView.currentItem && departmentListView.currentItem.visible
    }

    Image {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        fillMode: Image.Stretch
        source: "graphics/dash_divider_top_lightgrad.png"
        z: -1
    }

    Image {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        fillMode: Image.Stretch
        source: "graphics/dash_divider_top_darkgrad.png"
        z: -1
    }

    Label {
        anchors.fill: parent
        anchors.margins: units.gu(2)
        verticalAlignment: Text.AlignVCenter
        text: root.currentDepartment ? root.currentDepartment.label : ""
    }

    Image {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        rotation: showList ? 180 : 0
        source: "image://theme/dropdown-menu"
        sourceSize.height: parent.height - units.gu(2)
        sourceSize.width: units.gu(3)
        fillMode: Image.PreserveAspectFit
    }

    //  departmentListView is outside root
    ListView {
        id: departmentListView
        objectName: "departmentListView"
        orientation: ListView.Horizontal
        interactive: false
        clip: root.width != windowWidth
        model: ListModel {
            id: departmentModel
            // We have two roles
            // departmentId: the department id of the department the list represents
            // nullifyDepartment: overrides departmentId to be null
            //                    This is used to "clear" the delegate when going "right" on the tree
        }
        width: root.width
        readonly property int maxHeight: units.gu(60)
        property int prevHeight: maxHeight
        height: currentItem ? currentItem.height : maxHeight
        onHeightChanged: prevHeight = height;
        anchors.top: root.bottom
        delegate: DashDepartmentsList {
            objectName: "department" + index
            visible: height != 0
            width: departmentListView.width
            height: !root.showList ? 0 : department && department.loaded ? Math.min(implicitHeight, departmentListView.maxHeight) : departmentListView.prevHeight
            department: (nullifyDepartment || !scope) ? null : scope.getDepartment(departmentId)
            currentDepartment: root.currentDepartment
            onEnterDepartment: {
                scope.loadDepartment(newDepartmentId);
                // We only need to add a new item to the model
                // if we have children, otherwise just load it
                if (hasChildren) {
                    isGoingBack = false;
                    departmentModel.append({"departmentId": newDepartmentId, "nullifyDepartment": false});
                    departmentListView.currentIndex++;
                } else {
                    showList = false;
                }
            }
            onGoBackToParentClicked: {
                scope.loadDepartment(department.parentDepartmentId);
                isGoingBack = true;
                departmentModel.setProperty(departmentListView.currentIndex - 1, "nullifyDepartment", false);
                departmentListView.currentIndex--;
            }
            onAllDepartmentClicked: {
                showList = false;
                if (root.currentDepartment.count == 0) {
                    // For leaves we have to go to the parent too
                    scope.loadDepartment(root.currentDepartment.parentDepartmentId);
                }
            }
        }
        onContentXChanged: {
            if (contentX == width * departmentListView.currentIndex) {
                if (isGoingBack) {
                    departmentModel.remove(departmentListView.currentIndex + 1);
                } else {
                    departmentModel.setProperty(departmentListView.currentIndex - 1, "nullifyDepartment", true);
                }
            }
        }
    }

    InverseMouseArea {
        anchors.fill: departmentListView
        enabled: root.showList
        onClicked: root.showList = false
    }

    onScopeChanged: {
        departmentModel.clear();
        if (scope && scope.hasDepartments) {
            departmentModel.append({"departmentId": scope.currentDepartmentId, "nullifyDepartment": false});
        }
    }

    Connections {
        target: scope
        onHasDepartmentsChanged: {
            if (scope.hasDepartments) {
                departmentModel.append({"departmentId": scope.currentDepartmentId, "nullifyDepartment": false});
            } else {
                departmentModel.clear();
            }
        }
    }
}
