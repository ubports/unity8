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
    objectName: "dashNavigation"

    property var scope: null

    property bool showList: false

    readonly property var currentNavigation: scope && scope.hasNavigation ? scope.getNavigation(scope.currentNavigationId) : null

    property alias windowWidth: blackRect.width
    property alias windowHeight: blackRect.height
    property var scopeStyle: null

    // Are we drilling down the tree or up?
    property bool isGoingBack: false

    visible: root.currentNavigation != null

    height: visible ? units.gu(5) : 0

    onClicked: {
        departmentListView.updateMaxHeight();
        root.showList = !root.showList;
    }

    Rectangle {
        id: blackRect
        color: "black"
        opacity: navigationListView.currentItem && navigationListView.currentItem.visible ? 0.3 : 0
        Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }
        anchors.top: navigationListView.top
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
        text: root.currentNavigation ? root.currentNavigation.label : ""
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

    //  navigationListView is outside root
    ListView {
        id: navigationListView
        objectName: "navigationListView"
        orientation: ListView.Horizontal
        interactive: false
        clip: root.width != windowWidth
        model: ListModel {
            id: navigationModel
            // We have two roles
            // navigationId: the navigation id of the navigation the list represents
            // nullifyNavigation: overrides navigationId to be null
            //                    This is used to "clear" the delegate when going "right" on the tree
        }
        anchors {
            left: parent.left
            right: parent.right
            top: root.bottom
        }
        property int maxHeight: -1
        Component.onCompleted: updateMaxHeight();
        function updateMaxHeight()
        {
            maxHeight = (windowHeight - mapToItem(null, 0, 0).y) - units.gu(8);
        }
        property int prevHeight: maxHeight
        height: currentItem ? currentItem.height : maxHeight
        onHeightChanged: {
            if (root.showList) {
                prevHeight = currentItem.desiredHeight;
            }
        }
        highlightMoveDuration: UbuntuAnimation.FastDuration
        delegate: DashNavigationList {
            objectName: "navigation" + index
            visible: height != 0
            width: navigationListView.width
            scopeStyle: root.scopeStyle
            property real desiredHeight: {
                if (root.showList) {
                    if (navigation && navigation.loaded && x == navigationListView.contentX)
                    {
                        navigationListView.updateMaxHeight();
                        return Math.min(implicitHeight, navigationListView.maxHeight);
                    } else {
                        return navigationListView.prevHeight;
                    }
                } else {
                    return 0;
                }
            }
            height: desiredHeight
            navigation: (nullifyNavigation || !scope) ? null : scope.getNavigation(navigationId)
            currentNavigation: root.currentNavigation
            onEnterNavigation: {
                scope.setNavigationState(newNavigationId, false);
                // We only need to add a new item to the model
                // if we have children, otherwise just load it
                if (hasChildren) {
                    isGoingBack = false;
                    navigationModel.append({"navigationId": newNavigationId, "nullifyNavigation": false});
                    navigationListView.currentIndex++;
                } else {
                    showList = false;
                }
            }
            onGoBackToParentClicked: {
                scope.setNavigationState(navigation.parentNavigationId, false);
                isGoingBack = true;
                navigationModel.setProperty(navigationListView.currentIndex - 1, "nullifyNavigation", false);
                navigationListView.currentIndex--;
            }
            onAllNavigationClicked: {
                showList = false;
                if (root.currentNavigation.parentNavigationId == navigation.navigationId) {
                    // For leaves we have to go to the parent too
                    scope.setNavigationState(root.currentNavigation.parentNavigationId, false);
                }
            }
        }
        onContentXChanged: {
            if (contentX == width * navigationListView.currentIndex) {
                if (isGoingBack) {
                    navigationModel.remove(navigationListView.currentIndex + 1);
                } else {
                    navigationModel.setProperty(navigationListView.currentIndex - 1, "nullifyNavigation", true);
                }
            }
        }
    }

    InverseMouseArea {
        anchors.fill: navigationListView
        enabled: root.showList
        onClicked: root.showList = false
    }

    onScopeChanged: {
        navigationModel.clear();
        if (scope && scope.hasNavigation) {
            navigationModel.append({"navigationId": scope.currentNavigationId, "nullifyNavigation": false});
        }
    }

    Connections {
        target: scope
        onHasNavigationChanged: {
            if (scope.hasNavigation) {
                navigationModel.append({"navigationId": scope.currentNavigationId, "nullifyNavigation": false});
            } else {
                navigationModel.clear();
            }
        }
    }
}
