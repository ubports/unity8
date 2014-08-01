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
import Ubuntu.Components 1.1

AbstractButton {
    id: root
    objectName: "dashDepartments"

    property var scope: null

    property bool showList: false

    readonly property var currentDepartment: scope && scope.hasNavigation ? scope.getNavigation(scope.currentNavigationId) : null

    property alias windowWidth: blackRect.width
    property alias windowHeight: blackRect.height
    property var scopeStyle: null

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
        opacity: departmentListView.currentItem && departmentListView.currentItem.visible ? 0.3 : 0
        Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }
        anchors.top: departmentListView.top
        anchors.right: parent.right
        visible: opacity != 0
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
        color: root.scopeStyle ? root.scopeStyle.foreground : "grey"
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        name: showList ? "up" : "down"
        height: units.gu(2)
        width: height
        color: root.scopeStyle ? root.scopeStyle.foreground : "grey"
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
            // navigationId: the department id of the department the list represents
            // nullifyDepartment: overrides navigationId to be null
            //                    This is used to "clear" the delegate when going "right" on the tree
        }
        anchors {
            left: parent.left
            right: parent.right
            top: root.bottom
        }
        readonly property int maxHeight: (windowHeight - mapToItem(null, root.x, root.y).y) - units.gu(8)
        property int prevHeight: maxHeight
        height: currentItem ? currentItem.height : maxHeight
        onHeightChanged: {
            if (root.showList) {
                prevHeight = currentItem.desiredHeight;
            }
        }
        highlightMoveDuration: UbuntuAnimation.FastDuration
        delegate: DashDepartmentsList {
            objectName: "department" + index
            visible: height != 0
            width: departmentListView.width
            scopeStyle: root.scopeStyle
            property real desiredHeight: {
                if (root.showList) {
                    if (department && department.loaded && x == departmentListView.contentX)
                    {
                        return Math.min(implicitHeight, departmentListView.maxHeight);
                    } else {
                        return departmentListView.prevHeight;
                    }
                } else {
                    return 0;
                }
            }
            height: desiredHeight
            department: (nullifyDepartment || !scope) ? null : scope.getNavigation(navigationId)
            currentDepartment: root.currentDepartment
            onEnterDepartment: {
                scope.performQuery(departmentQuery);
                // We only need to add a new item to the model
                // if we have children, otherwise just load it
                if (hasChildren) {
                    isGoingBack = false;
                    departmentModel.append({"navigationId": newNavigationId, "nullifyDepartment": false});
                    departmentListView.currentIndex++;
                } else {
                    showList = false;
                }
            }
            onGoBackToParentClicked: {
                scope.performQuery(department.parentQuery);
                isGoingBack = true;
                departmentModel.setProperty(departmentListView.currentIndex - 1, "nullifyDepartment", false);
                departmentListView.currentIndex--;
            }
            onAllDepartmentClicked: {
                showList = false;
                if (root.currentDepartment.parentNavigationId == department.navigationId) {
                    // For leaves we have to go to the parent too
                    scope.performQuery(root.currentDepartment.parentQuery);
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
        if (scope && scope.hasNavigation) {
            departmentModel.append({"navigationId": scope.currentNavigationId, "nullifyDepartment": false});
        }
    }

    Connections {
        target: scope
        onHasNavigationChanged: {
            if (scope.hasNavigation) {
                departmentModel.append({"navigationId": scope.currentNavigationId, "nullifyDepartment": false});
            } else {
                departmentModel.clear();
            }
        }
    }
}
