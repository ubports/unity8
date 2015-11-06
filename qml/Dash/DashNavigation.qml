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
    property bool isEnteringChildren: false

    visible: height != 0
    implicitHeight: navigationListView.y + navigationListView.height

    function resetNavigation() {
        if (navigationModel.count > 1) {
            clear();
        }
    }

    QtObject {
        id: d
        readonly property color foregroundColor: root.scopeStyle
                                                 ? root.scopeStyle.getTextColor(backgroundItem.luminance)
                                                 : theme.palette.normal.baseText
    }

    Column {
        id: headersColumn
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        function pop(popsNeeded) {
            if (popsNeeded == 0)
                return;
            isEnteringChildren = false;
            navigationListView.currentIndex = navigationListView.currentIndex - popsNeeded;
            navigationModel.setProperty(navigationListView.currentIndex, "nullifyNavigation", false);
            navigationModel.remove(navigationModel.count - popsNeeded, popsNeeded);

            popsNeeded = Math.min(headersModel.count, popsNeeded);
            // This is effectively deleting ourselves, so needs to be the last thing of the function
            headersModel.remove(headersModel.count - popsNeeded, popsNeeded);
        }

        Repeater {
            model: ListModel {
                id: headersModel
                // Roles
                // headerText: the text to show
                // navigationId: the navigation Id that represents
                // parentNavigationId: the parent navigation Id
            }
            delegate: DashNavigationHeader {
                objectName: "dashNavigationHeader" + index
                height: index == 0 && headersModel.count > 1 ? 0 : units.gu(5)
                width: parent.width

                backVisible: index != 0
                text: headerText
                foregroundColor: d.foregroundColor

                onBackClicked: {
                    scope.setNavigationState(parentNavigationId);

                    var popsNeeded = headersModel.count - index;
                    headersColumn.pop(popsNeeded);
                }

                onTextClicked: {
                    scope.setNavigationState(navigationId);

                    var popsNeeded = headersModel.count - index - 1;
                    headersColumn.pop(popsNeeded);

                    root.leafClicked();
                }
            }
        }
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
        anchors {
            top: headersColumn.bottom
            left: parent.left
            right: parent.right
        }
        property int maxHeight: -1
        Component.onCompleted: updateMaxHeight();
        function updateMaxHeight()
        {
            maxHeight = root.availableHeight - mapToItem(root, 0, 0).y;
        }
        property int prevHeight: maxHeight
        height: currentItem ? currentItem.height : maxHeight

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
            itemsIndent: index != 0 ? units.gu(5) : 0
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
            onEnterNavigation: { // var newNavigationId, string newNavigationLabel, bool hasChildren
                scope.setNavigationState(newNavigationId);
                // We only need to add a new item to the model
                // if we have children, otherwise just load it
                if (hasChildren) {
                    isEnteringChildren = true;
                    navigationModel.append({"navigationId": newNavigationId, "nullifyNavigation": false});
                    headersModel.append({"headerText": newNavigationLabel,
                                         "navigationId": newNavigationId,
                                         "parentNavigationId": navigationId
                                        });
                    navigationListView.currentIndex++;
                } else {
                    root.leafClicked();
                }
            }
        }
        onContentXChanged: {
            if (navigationListView.highlightMoveDuration == 0)
                return;

            if (contentX == width * navigationListView.currentIndex) {
                if (isEnteringChildren) {
                    navigationModel.setProperty(navigationListView.currentIndex - 1, "nullifyNavigation", true);
                }
            }
        }
    }

    property bool isFirstLoad: false
    onScopeChanged: clear();
    function clear() {
        navigationModel.clear();
        headersModel.clear();
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
            headersModel.append({"headerText": currentNavigation.allLabel != "" ? currentNavigation.allLabel : currentNavigation.label,
                                 "navigationId": currentNavigation.navigationId,
                                 "parentNavigationId": currentNavigation.parentNavigationId
                                });
        }
    }
    Connections {
        target: currentNavigation
        onLoadedChanged: setNewNavigation();
    }
    onCurrentNavigationChanged: setNewNavigation();
}
