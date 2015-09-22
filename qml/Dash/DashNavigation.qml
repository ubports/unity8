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
import Dash 0.1

Item {
    id: root
    objectName: "dashNavigation"

    // set by parent
    property var scope: null
    property var scopeStyle: null
    property real availableHeight

    signal leafClicked()

    // internal
    readonly property var currentNavigation: scope && scope.hasNavigation ? scope.getNavigation(scope.currentNavigationId) : null
    // Are we drilling down the tree or up?
    property bool isGoingBack: false

    visible: height != 0
    implicitHeight: navigationListView.y + navigationListView.height

    QtObject {
        id: d
        readonly property color foregroundColor: root.scopeStyle
                                                 ? root.scopeStyle.getTextColor(backgroundItem.luminance)
                                                 : Theme.palette.normal.baseText
    }

    Label {
        id: label
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: units.gu(2)
        text: root.currentNavigation ? root.currentNavigation.label : ""
        color: d.foregroundColor
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    ListView {
        id: navigationListView
        objectName: "navigationListView"
        orientation: ListView.Horizontal
        interactive: false
        model: ListModel {
            id: navigationModel
            // We have two roles
            // navigationId: the navigation id of the navigation the list represents
            // nullifyNavigation: overrides navigationId to be null
            //                    This is used to "clear" the delegate when going "right" on the tree
        }
        anchors.top: label.bottom
        property int maxHeight: -1
        Component.onCompleted: updateMaxHeight();
        function updateMaxHeight()
        {
            maxHeight = root.availableHeight - mapToItem(root, 0, 0).y;
        }
        property int prevHeight: maxHeight
        height: currentItem ? currentItem.height : maxHeight
        width: parent.width

        onHeightChanged: {
            if (currentItem) {
                prevHeight = currentItem.desiredHeight;
            }
        }
        highlightMoveDuration: UbuntuAnimation.FastDuration
        delegate: DashNavigationList {
            objectName: "navigation" + index
            visible: height > 0
            width: navigationListView.width
            scopeStyle: root.scopeStyle
            foregroundColor: d.foregroundColor
            property real desiredHeight: {
                if (navigation && navigation.loaded && x == navigationListView.contentX)
                {
                    navigationListView.updateMaxHeight();
                    return Math.min(implicitHeight, navigationListView.maxHeight);
                } else {
                    return navigationListView.prevHeight;
                }
            }
            height: desiredHeight
            navigation: (nullifyNavigation || !scope) ? null : scope.getNavigation(navigationId)
            currentNavigation: root.currentNavigation
            onEnterNavigation: {
                scope.setNavigationState(newNavigationId);
                // We only need to add a new item to the model
                // if we have children, otherwise just load it
                if (hasChildren) {
                    isGoingBack = false;
                    navigationModel.append({"navigationId": newNavigationId, "nullifyNavigation": false});
                    navigationListView.currentIndex++;
                } else {
                    root.leafClicked();
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

                scope.setNavigationState(navigation.parentNavigationId);
                isGoingBack = true;
                navigationModel.setProperty(navigationListView.currentIndex - 1, "nullifyNavigation", false);
                navigationListView.currentIndex--;
            }
            onAllNavigationClicked: {
                root.leafClicked();
                if (root.currentNavigation.parentNavigationId == navigation.navigationId) {
                    // For leaves we have to go to the parent too
                    scope.setNavigationState(root.currentNavigation.parentNavigationId);
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
                navigationModel.append({"navigationId": scope.currentNavigationId, "nullifyNavigation": false});
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
}
