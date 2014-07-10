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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import Unity 0.2
import Utils 0.1
import "../Components"

Item {
    id: dashContent

    property var model: null
    property var scopes: null
    readonly property alias currentIndex: dashContentList.currentIndex
    property alias overviewHandleHeight: overviewDragHandle.height

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
            if (scopes.loaded) {
                if (set_current_index != undefined) {
                    setCurrentScopeAtIndex(set_current_index[0], set_current_index[1], set_current_index[2]);
                    set_current_index = undefined;
                }
                scopesOverview.scope = scopes.getScope("scopesOverview");
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

        if (dashContentList.count > index)
        {
            dashContentList.currentIndex = index

            if (reset) {
                dashContentList.currentItem.item.positionAtBeginning()
            }
        }

        if (!animate) {
            dashContentList.highlightMoveDuration = storedMoveDuration
            dashContentList.highlightMoveVelocity = storedMoveSpeed
        }
    }

    function closeScope(scope) {
        dashContentList.currentItem.theScope.closeScope(scope)
    }

    QtObject {
        id: overviewController

        property bool accepted: false
        property bool enableAnimation: false
        property real progress: 0
    }

    ScopesOverview {
        id: scopesOverview
        anchors.fill: parent
        scope: scopes ? scopes.getScope("scopesOverview") : null
        progress: overviewController.progress
        onDone: {
            overviewController.enableAnimation = true;
            overviewController.progress = 0;
            overviewController.accepted = false;
        }
    }

    Item {
        id: dashContentListHolder

        anchors.fill: parent

        enabled: scale == 1

        Image {
            anchors.fill: parent
            source: parent.width > parent.height ? "graphics/paper_landscape.png" : "graphics/paper_portrait.png"
            fillMode: Image.PreserveAspectCrop
            horizontalAlignment: Image.AlignRight
            verticalAlignment: Image.AlignTop
        }

        ListView {
            id: dashContentList
            objectName: "dashContentList"

            interactive: dashContent.scopes.loaded && currentItem && !currentItem.moving

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
            onMovementStarted: currentItem.item.showHeader();
            clip: parent.x != 0 || parent.scale != 1

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
                    width: ListView.view.width
                    height: ListView.view.height
                    asynchronous: true
                    // TODO This if will eventually go away since we're killing DashApps.qml
                    // once we move app closing to the spread
                    source: (scope.id == "clickscope") ? "DashApps.qml" : "GenericScopeView.qml"
                    objectName: scope.id + " loader"

                    readonly property bool moving: item ? item.moving : false
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

        scale: 1 - overviewController.progress * 0.6
        Behavior on scale {
            id: dashContentScaleAnimation
            enabled: overviewController.enableAnimation
            UbuntuNumberAnimation { }
        }
    }

    EdgeDragArea {
        id: overviewDragHandle
        direction: Direction.Upwards
        distanceThreshold: units.gu(20)
        enabled: !overviewController.accepted || dragging

        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: units.gu(2)

        onSceneDistanceChanged: {
            overviewController.enableAnimation = false;
            overviewController.progress = Math.min(1, sceneDistance / distanceThreshold);
        }

        onStatusChanged: {
            if (status == DirectionalDragArea.Recognized) {
                overviewController.accepted = true;
            }
        }

        onDraggingChanged: {
            overviewController.enableAnimation = true;
            overviewController.progress = overviewController.accepted ? 1 : 0;
        }
    }
}
