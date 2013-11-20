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

Item {
    id: dashContent

    property var model: null
    property var scopes: null
    property real contentProgress: Math.max(0, Math.min(dashContentList.contentX / (dashContentList.contentWidth - dashContentList.width), units.dp(1)))
    property alias currentIndex: dashContentList.currentIndex

    property ScopeDelegateMapper scopeMapper : ScopeDelegateMapper {}

    signal movementStarted()
    signal movementEnded()
    signal contentFlickStarted()
    signal contentEndReached()
    signal previewShown()
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

    ListView {
        id: dashContentList
        objectName: "dashContentList"

        interactive: dashContent.scopes.loaded && !currentItem.previewShown && !currentItem.moving

        anchors.fill: parent
        model: dashContent.model
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.DragAndOvershootBounds
        flickDeceleration: units.gu(625)
        maximumFlickVelocity: width * 5
        snapMode: ListView.SnapOneItem
        highlightMoveDuration: 250
        highlightRangeMode: ListView.StrictlyEnforceRange
        /* FIXME: workaround rendering issue due to use of ShaderEffectSource in
           UbuntuShape. While switching from the home scope to the People scope the
           rendering would block midway.
        */
        cacheBuffer: 2147483647
        onMovementStarted: dashContent.movementStarted()
        onMovementEnded: dashContent.movementEnded()

        // If the number of items is less than the current index, then need to reset to another item.
        onCountChanged: {
            if (currentIndex >= count)
                dashContent.setCurrentScopeAtIndex(count-1, true, true)
        }

        delegate:
            Loader {
                width: ListView.view.width
                height: ListView.view.height
                asynchronous: true
                source: scopeMapper.map(scope.id)
                objectName: scope.id + " loader"

                readonly property bool previewShown: item ? item.previewShown : false
                readonly property bool moving: item ? item.moving : false

                // these are needed for autopilot tests
                readonly property string scopeId: scope.id
                readonly property bool isCurrent: ListView.isCurrentItem
                readonly property bool isLoaded: status == Loader.Ready

                onLoaded: {
                    item.scope = Qt.binding(function() { return scope })
                    item.isCurrent = Qt.binding(function() { return visible && ListView.isCurrentItem })
                    item.searchHistory = Qt.binding(function() { return shell.searchHistory })
                    dashContentList.movementStarted.connect(item.movementStarted)
                    dashContent.positionedAtBeginning.connect(item.positionedAtBeginning)
                    dashContent.scopeLoaded(item.scope.id)
                }
                Connections {
                    target: item
                    ignoreUnknownSignals: true
                    onEndReached: contentEndReached()
                    onPreviewShownChanged: {
                        if (item.previewShown) {
                            dashContent.previewShown()
                        }
                    }
                }

                Component.onDestruction: active = false
            }
    }
}
