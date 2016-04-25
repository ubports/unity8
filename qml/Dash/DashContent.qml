/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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
import Unity 0.2
import Utils 0.1
import "../Components"

Item {
    id: dashContent

    property bool forceNonInteractive: false
    property alias scopes: dashContentList.model
    property alias currentIndex: dashContentList.currentIndex
    property int workaroundRestoreIndex: -1
    readonly property string currentScopeId: dashContentList.currentItem ? dashContentList.currentItem.scopeId : ""
    readonly property var currentScope: dashContentList.currentItem ? dashContentList.currentItem.theScope : null
    readonly property bool subPageShown: dashContentList.currentItem && dashContentList.currentItem.item ?
                                            dashContentList.currentItem.item.subPageShown : false
    readonly property bool processing: dashContentList.currentItem && dashContentList.currentItem.item
                                       && dashContentList.currentItem.item.processing || false
    readonly property bool pageHeaderTotallyVisible: dashContentList.currentItem && dashContentList.currentItem.item
                                       && dashContentList.currentItem.item.pageHeaderTotallyVisible || false

    signal scopeLoaded(string scopeId)
    signal gotoScope(string scopeId)
    signal openScope(var scope)
    signal closePreview()

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
        onRowsMoved: {
            // FIXME This is to workaround a Qt bug with the model moving the current item
            // when the list is ListView.SnapOneItem and ListView.StrictlyEnforceRange
            // together with the code in Dash.qml
            if (row == dashContentList.currentIndex || start == dashContentList.currentIndex) {
                dashContent.workaroundRestoreIndex = dashContentList.currentIndex;
                dashContentList.currentIndex = -1;
            }
        }
    }

    function setCurrentScopeAtIndex(index, animate, reset) {
        // if the scopes haven't loaded yet, then wait until they are.
        if (!scopes.loaded) {
            set_current_index = [ index, animate, reset ]
            return;
        }

        var storedMoveDuration = dashContentList.highlightMoveDuration
        var storedMoveSpeed = dashContentList.highlightMoveVelocity
        if (!animate) {
            dashContentList.highlightMoveVelocity = units.gu(4167)
            dashContentList.highlightMoveDuration = 0
        }

        set_current_index = undefined;

        if (dashContentList.count > index) {
            dashContentList.currentIndex = index

            if (reset) {
                dashContentList.currentItem.item.positionAtBeginning()
                dashContentList.currentItem.item.resetSearch()
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

        DashBackground {
            anchors.fill: parent
        }

        ListView {
            id: dashContentList
            objectName: "dashContentList"

            interactive: !dashContent.forceNonInteractive && dashContent.scopes.loaded && currentItem
                         && !currentItem.moving && !currentItem.subPageShown && !currentItem.extraPanelShown
            anchors.fill: parent
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.DragAndOvershootBounds
            flickDeceleration: units.gu(625)
            maximumFlickVelocity: width * 5
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: 250
            highlightRangeMode: ListView.StrictlyEnforceRange
            // TODO Investigate if we can switch to a smaller cache buffer when/if UbuntuShape gets more performant
            // 1073741823 is s^30 -1. A quite big number so that you have "infinite" cache, but not so
            // big so that if you add if with itself you're outside the 2^31 int range
            cacheBuffer: 1073741823
            onMovementStarted: currentItem.item.showHeader();
            clip: parent.x != 0

            // TODO QTBUG-40846 and QTBUG-40848
            // The remove transition doesn't happen when removing the last item
            // And can't work around it because index is reset to -1 regardless of
            // ListView.delayRemove

            remove: Transition {
                SequentialAnimation {
                    PropertyAction { property: "layer.enabled"; value: true }
                    PropertyAction { property: "ListView.delayRemove"; value: true }
                    ParallelAnimation {
                        PropertyAnimation { properties: "scale"; to: 0.25; duration: UbuntuAnimation.SnapDuration }
                        PropertyAnimation { properties: "y"; to: dashContent.height; duration: UbuntuAnimation.SnapDuration }
                    }
                    PropertyAction { property: "ListView.delayRemove"; value: false }
                }
            }
            removeDisplaced: Transition {
                PropertyAnimation { property: "x"; duration: UbuntuAnimation.SnapDecision }
            }

            // If the number of items is less than the current index, then need to reset to another item.
            onCountChanged: {
                if (count > 0) {
                    if (currentIndex >= count) {
                        dashContent.setCurrentScopeAtIndex(count-1, true, true)
                    } else if (currentIndex < 0) {
                        // setting currentIndex directly, cause we don't want to loose set_current_index
                        dashContentList.currentIndex = 0
                    }
                }
            }

            delegate:
                Loader {
                    id: loader
                    width: ListView.view.width
                    height: ListView.view.height
                    opacity: { // hide delegate if offscreen
                        var xPositionRelativetoView = ListView.view.contentX - x
                        return (xPositionRelativetoView > -width && xPositionRelativetoView < width) ? 1 : 0
                    }
                    asynchronous: true
                    source: "GenericScopeView.qml"
                    objectName: "scopeLoader" + index

                    readonly property bool moving: item ? item.moving : false
                    readonly property bool extraPanelShown: item ? item.extraPanelShown : false
                    readonly property bool subPageShown: item ? item.subPageShown : false
                    readonly property var categoryView: item ? item.categoryView : null
                    readonly property var theScope: scope

                    // these are needed for autopilot tests
                    readonly property string scopeId: scope.id
                    readonly property bool isCurrent: ListView.isCurrentItem
                    readonly property bool isLoaded: status == Loader.Ready

                    onLoaded: {
                        item.objectName = scope.id
                        item.scope = Qt.binding(function() { return scope })
                        item.isCurrent = Qt.binding(function() { return visible && ListView.isCurrentItem })
                        dashContent.scopeLoaded(item.scope.id)
                        item.paginationCount = Qt.binding(function() { return dashContentList.count } )
                        item.paginationIndex = Qt.binding(function() { return dashContentList.currentIndex } )
                        item.visibleToParent = Qt.binding(function() { return loader.opacity != 0 });
                        item.holdingList = dashContentList;
                        item.forceNonInteractive = Qt.binding(function() { return dashContent.forceNonInteractive } )
                    }
                    Connections {
                        target: isCurrent ? scope : null
                        onGotoScope: {
                            // Note here scopeId is the signal parameter and not the loader property
                            dashContent.gotoScope(scopeId);
                        }
                        onOpenScope: {
                            dashContent.openScope(scope);
                        }
                    }
                    Connections {
                        target: dashContent
                        onClosePreview: if (item) item.closePreview()
                    }

                    Component.onDestruction: active = false
                }
        }
    }
}
