/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import Ubuntu.Components 1.3

AbstractButton {
    id: root
    objectName: "dashNavigation"

    // Set by parent
    property var scope: null
    property var scopeStyle: null
    property color foregroundColor: theme.palette.normal.baseText
    property bool isAltNavigation: false
    property bool showDivider: false

    // Used by parent
    readonly property var currentNavigation: scope && scope[hasNavigation] ? getNavigation(scope[currentNavigationId]) : null
    readonly property alias listView: navigationListView
    readonly property bool inverseMousePressed: inverseMouseArea.pressed
    property bool showList: false

    // Internal
    // Are we drilling down the tree or up?
    property bool isGoingBack: false
    readonly property string hasNavigation: isAltNavigation ? "hasAltNavigation" : "hasNavigation"
    readonly property string currentNavigationId: isAltNavigation ? "currentAltNavigationId" : "currentNavigationId"
    function getNavigation(navId) {
        if (isAltNavigation) {
            return scope.getAltNavigation(navId);
        } else {
            return scope.getNavigation(navId);
        }
    }

    visible: root.currentNavigation != null

    onClicked: {
        navigationListView.updateMaxHeight();
        root.showList = !root.showList;
    }

    Label {
        anchors.fill: parent
        anchors.margins: units.gu(2)
        anchors.rightMargin: units.gu(5)
        verticalAlignment: Text.AlignVCenter
        text: root.currentNavigation ? root.currentNavigation.label : ""
        color: root.foregroundColor
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        name: showList ? "up" : "down"
        height: units.gu(2)
        width: height
        color: root.foregroundColor
    }

    //  navigationListView is outside root
    ListView {
        id: navigationListView
        objectName: "navigationListView"
        visible: height > 0
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
        anchors.top: root.bottom
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
            visible: height > 0
            width: navigationListView.width
            scopeStyle: root.scopeStyle
            foregroundColor: root.foregroundColor
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
            navigation: (nullifyNavigation || !scope) ? null : getNavigation(navigationId)
            currentNavigation: root.currentNavigation
            onEnterNavigation: {
                scope.setNavigationState(newNavigationId, isAltNavigation);
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
                if (navigationListView.currentIndex == 0) {
                    // This can happen if we jumped to the non root of a deep tree and the user
                    // is now going back, create space in the list for the list to move "left"
                    var aux = navigationListView.highlightMoveDuration;
                    navigationListView.highlightMoveDuration = 0;
                    navigationModel.insert(0, {"navigationId": navigation.parentNavigationId, "nullifyNavigation": false});
                    navigationListView.currentIndex = navigationListView.currentIndex + 1;
                    navigationListView.contentX = width * navigationListView.currentIndex;
                    navigationListView.highlightMoveDuration = aux;
                }

                scope.setNavigationState(navigation.parentNavigationId, isAltNavigation);
                isGoingBack = true;
                navigationModel.setProperty(navigationListView.currentIndex - 1, "nullifyNavigation", false);
                navigationListView.currentIndex--;
            }
            onAllNavigationClicked: {
                showList = false;
                if (root.currentNavigation.parentNavigationId == navigation.navigationId) {
                    // For leaves we have to go to the parent too
                    scope.setNavigationState(root.currentNavigation.parentNavigationId, isAltNavigation);
                }
            }
        }
        onContentXChanged: {
            if (navigationListView.highlightMoveDuration == 0)
                return;

            if (contentX == width * navigationListView.currentIndex) {
                if (isGoingBack) {
                    navigationModel.remove(navigationListView.currentIndex + 1);
                } else {
                    navigationModel.setProperty(navigationListView.currentIndex - 1, "nullifyNavigation", true);
                }
            }
        }
    }

    Image {
        anchors {
            top: navigationListView.bottom
            left: navigationListView.left
            right: navigationListView.right
        }
        fillMode: Image.Stretch
        source: "graphics/navigation_shadow.png"
        visible: root.showList
    }

    property bool isFirstLoad: false
    onScopeChanged: {
        navigationModel.clear();
        isFirstLoad = true;
    }
    function setNewNavigation() {
        if (isFirstLoad && currentNavigation && currentNavigation.loaded) {
            isFirstLoad = false;
            if (currentNavigation.count > 0) {
                navigationModel.append({"navigationId": scope[currentNavigationId], "nullifyNavigation": false});
            } else {
                navigationModel.append({"navigationId": currentNavigation.parentNavigationId, "nullifyNavigation": false});
            }
        }
    }
    Connections {
        target: currentNavigation
        onLoadedChanged: setNewNavigation();
    }
    onCurrentNavigationChanged: setNewNavigation();

    InverseMouseArea {
        id: inverseMouseArea
        anchors.fill: navigationListView
        enabled: root.showList
        onPressed: root.showList = false
    }

    Rectangle {
        visible: root.showDivider
        anchors {
            top: parent.top
            topMargin: units.dp(1)
            bottom: parent.bottom
            left: parent.right
            leftMargin: -units.dp(0.5)
        }
        width: units.dp(1)
        color: root.foregroundColor
        opacity: 0.2
    }
}
