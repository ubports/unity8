/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity 0.1
import "../Components"

Item {
    id: dashContent

    property var model: null
    property var scopes: null
    property alias currentIndex: dashContentList.currentIndex

    property ScopeDelegateMapper scopeMapper : ScopeDelegateMapper {}
    property ListModel searchHistory

    signal movementStarted()
    signal movementEnded()
    signal scopeLoaded(string scopeId)
    signal positionedAtBeginning()

    // If we set the current scope index before the scopes have been added,
    // then we need to wait until the loaded signals gets emitted from the scopes
    property var set_current_index: undefined
    Connections {
        target: scopes
        onLoadedChanged: {
            if (scopes.loaded && set_current_index != undefined) {
                setCurrentScopeAtIndex(set_current_index[0], set_current_index[1], set_current_index[2]);
                set_current_index = undefined;
            }
        }
    }

    function setCurrentScopeAtIndex(index, animate, reset) {
        var storedMoveDuration = dashContentList.highlightMoveDuration
        var storedMoveSpeed = dashContentList.highlightMoveVelocity
        if (!animate) {
            dashContentList.highlightMoveVelocity = units.gu(4167)
            dashContentList.highlightMoveDuration = 0
        }

        // if the scopes haven't loaded yet, then wait until they are.
        if (!scopes.loaded) {
            set_current_index = [ index, animate, reset ]
            return;
        }
        set_current_index = undefined;

        if (dashContentList.count > index)
        {
            dashContentList.currentIndex = index

            if (reset) {
                dashContent.positionedAtBeginning()
            }
        }

        if (!animate) {
            dashContentList.highlightMoveDuration = storedMoveDuration
            dashContentList.highlightMoveVelocity = storedMoveSpeed
        }
    }

    Item {
        id: dashContentListHolder
        anchors.fill: parent

        ListView {
            id: dashContentList
            objectName: "dashContentList"

            interactive: dashContent.scopes.loaded && !previewListView.onScreen && !currentItem.moving

            anchors.fill: parent
            model: dashContent.model
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.DragAndOvershootBounds
            flickDeceleration: units.gu(625)
            maximumFlickVelocity: width * 5
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: 250
            highlightRangeMode: ListView.StrictlyEnforceRange
            // TODO Investigate if we can switch to a smaller cache buffer when/if UbuntuShape gets more performant
            cacheBuffer: 1073741823
            onMovementStarted: dashContent.movementStarted()
            onMovementEnded: dashContent.movementEnded()

            // If the number of items is less than the current index, then need to reset to another item.
            onCountChanged: {
                if (count > 0) {
                    if (currentIndex >= count) {
                        dashContent.setCurrentScopeAtIndex(count-1, true, true)
                    } else if (currentIndex < 0) {
                        // setting currentIndex directly, cause we don't want to loose set_current_index
                        dashContent.currentIndex = 0
                    }
                }
            }

            delegate:
                Loader {
                    width: ListView.view.width
                    height: ListView.view.height
                    asynchronous: true
                    source: scopeMapper.map(scope.id)
                    objectName: scope.id + " loader"

                    readonly property bool moving: item ? item.moving : false
                    readonly property var categoryView: item ? item.categoryView : null
                    readonly property Scope theScope: scope

                    // these are needed for autopilot tests
                    readonly property string scopeId: scope.id
                    readonly property bool isCurrent: ListView.isCurrentItem
                    readonly property bool isLoaded: status == Loader.Ready

                    onLoaded: {
                        item.scope = Qt.binding(function() { return scope })
                        item.isCurrent = Qt.binding(function() { return visible && ListView.isCurrentItem })
                        item.tabBarHeight = pageHeader.implicitHeight;
                        item.pageHeader = pageHeader;
                        item.openEffect = openEffect;
                        item.previewListView = previewListView;
                        dashContentList.movementStarted.connect(item.movementStarted)
                        dashContent.positionedAtBeginning.connect(item.positionedAtBeginning)
                        dashContent.scopeLoaded(item.scope.id)
                    }

                    Component.onDestruction: active = false
                }
        }

        PageHeader {
            id: pageHeader
            objectName: "pageHeader"
            width: parent.width
            searchEntryEnabled: true
            searchHistory: dashContent.searchHistory
            scope: dashContentList.currentItem.theScope

            childItem: TabBar {
                id: tabBar
                objectName: "tabbar"
                height: units.gu(7)
                width: parent.width
                selectionMode: false
                style: DashContentTabBarStyle {}

                model: dashContentList.model

                onSelectedIndexChanged: {
                    dashContentList.currentIndex = selectedIndex;
                }

                Connections {
                    target: dashContentList
                    onCurrentIndexChanged: {
                        tabBar.selectedIndex = dashContentList.currentIndex
                    }
                }

                Connections {
                    target: model
                    onCountChanged: {
                        if (tabBar.selectedIndex < 0 && model.count > 0)
                            tabBar.selectedIndex = 0;
                    }
                }

                Component.onCompleted: {
                    __styleInstance.headerTextStyle = Text.Raised
                    __styleInstance.headerTextStyleColor = "black"
                }
            }
        }
    }

    DashContentOpenEffect {
        id: openEffect
        anchors {
            fill: parent
            bottomMargin: -bottomOverflow
        }
        sourceItem: dashContentListHolder
        previewListView: previewListView
    }

    PreviewListView {
        id: previewListView
        openEffect: openEffect
        categoryView: dashContentList.currentItem ? dashContentList.currentItem.categoryView : null
        scope: dashContentList.currentItem ? dashContentList.currentItem.theScope : null
        anchors.fill: parent
    }
}
