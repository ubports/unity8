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

Showable {
    id: dash
    objectName: "dash"

    visible: shown

    property string showScopeOnLoaded: "clickscope"
    property real contentScale: 1.0

    property alias overviewHandleHeight: overviewDragHandle.height

    function setCurrentScope(scopeId, animate, reset) {
        var scopeIndex = filteredScopes.findFirst(Scopes.RoleId, scopeId)

        if (scopeIndex == -1) {
            console.warn("No match for scope with id: %1".arg(scopeId))
            return
        }

        closeOverlayScope();

        dashContent.closePreview();

        if (scopeIndex == dashContent.currentIndex && !reset) {
            // the scope is already the current one
            return
        }

        dashContent.setCurrentScopeAtIndex(scopeIndex, animate, reset)
    }

    function closeOverlayScope() {
        if (dashContent.x != 0) {
            dashContent.x = 0;
        }
    }

    SortFilterProxyModel {
        id: filteredScopes
        model: Scopes {
            id: scopes
            onLoadedChanged: {
                if (loaded) {
                    scopesOverview.scope = scopes.getScope("scopesOverview");
                }
            }
        }
        dynamicSortFilter: true

        filterRole: Scopes.RoleVisible
        filterRegExp: RegExp("^true$")
    }

    QtObject {
        id: overviewController

        property bool accepted: false
        property alias enableAnimation: progressAnimation.enabled
        property real progress: 0
        property bool showingNonFavoriteScope: false
        Behavior on progress {
            id: progressAnimation
            UbuntuNumberAnimation { }
        }
    }

    ScopesOverview {
        id: scopesOverview
        anchors.fill: parent
        scope: scopes ? scopes.getScope("scopesOverview") : null
        showingNonFavoriteScope: overviewController.showingNonFavoriteScope
        progress: overviewController.progress
        scopeScale: 1 - overviewController.progress * 0.6
        visible: scopeScale != 1
        currentIndex: dashContent.currentIndex
        onDone: hide();
        onFavoriteSelected: {
            dashContent.setCurrentScopeAtIndex(index, false, false);
            hide();
        }
        function hide() {
            overviewController.enableAnimation = true;
            overviewController.progress = 0;
            overviewController.accepted = false;
        }

        Connections {
            target: scopesOverview.scope
            onOpenScope: {
                scopeItem.scope = scope;
                scopeItem.overviewScale = scopesOverview.allCardSize.width / scopeItem.width;
                scopeItem.x = scopesOverview.allScopeClickedPos.x -(scopeItem.width - scopeItem.width * scopeItem.overviewScale) / 2;
                scopeItem.y = scopesOverview.allScopeClickedPos.y -(scopeItem.height - scopeItem.height * scopeItem.overviewScale) / 2;
                overviewController.showingNonFavoriteScope = true;
                scopeItem.overviewScale = 1;
                scopeItem.x = 0;
                scopeItem.y = 0;
            }
        }
    }

    DashContent {
        id: dashContent
        parent: overviewController.progress == 0 ? dash : scopesOverview.dashItemEater
        objectName: "dashContent"
        width: dash.width
        height: dash.height
        model: filteredScopes
        scopes: scopes
        visible: !overviewController.showingNonFavoriteScope && x != -width
        onGotoScope: {
            dash.setCurrentScope(scopeId, true, false);
        }
        onOpenScope: {
            scopeItem.scope = scope;
            x = -width;
        }
        onScopeLoaded: {
            if (scopeId == dash.showScopeOnLoaded) {
                dash.setCurrentScope(scopeId, false, false)
                dash.showScopeOnLoaded = ""
            }
        }
        scale: dash.contentScale
        clip: scale != 1.0 || scopeItem.visible || overviewController.progress != 0
        Behavior on x {
            UbuntuNumberAnimation {
                onRunningChanged: {
                    if (!running && dashContent.x == 0) {
                        dashContent.closeScope(scopeItem.scope);
                        scopeItem.scope = null;
                    }
                }
            }
        }

        enabled: opacity == 1
        opacity: 1 - overviewController.progress
    }

    DashBackground
    {
        anchors.fill: scopeItem
        scale: scopeItem.scale
        visible: scopeItem.visible
    }

    GenericScopeView {
        id: scopeItem

        property real overviewScale: 1

        // TODO test this width + dashContent.x still works
        x: overviewController.showingNonFavoriteScope ? 0 : width + dashContent.x
        Behavior on x {
            enabled: overviewController.showingNonFavoriteScope
            UbuntuNumberAnimation { }
        }
        Behavior on y {
            enabled: overviewController.showingNonFavoriteScope
            UbuntuNumberAnimation { }
        }
        width: parent.width
        height: parent.height
        scale: dash.contentScale * overviewScale
        enabled: scale == 1
        Behavior on overviewScale {
            enabled: overviewController.showingNonFavoriteScope
            UbuntuNumberAnimation {
                onRunningChanged: {
                    if (!running && scopeItem.overviewScale != 1) {
                        scopesOverview.scope.closeScope(scopeItem.scope);
                        overviewController.showingNonFavoriteScope = false;
                        scopeItem.scope = null;
                    }
                }
            }
        }
        clip: scale != 1.0
        visible:  scope != null
        hasBackAction: true
        isCurrent: visible
        onBackClicked: {
            if (overviewController.showingNonFavoriteScope) {
                var v = scopesOverview.allCardSize.width / scopeItem.width;
                scopeItem.overviewScale = v;
                scopeItem.x = scopesOverview.allScopeClickedPos.x -(scopeItem.width - scopeItem.width * v) / 2;
                scopeItem.y = scopesOverview.allScopeClickedPos.y -(scopeItem.height - scopeItem.height * v) / 2;
            } else {
                closeOverlayScope();
                closePreview();
            }
        }

        Connections {
            target: scopeItem.scope
            onGotoScope: {
                dashContent.gotoScope(scopeId);
            }
            onOpenScope: {
                dashContent.openScope(scope);
            }
        }
    }

    EdgeDragArea {
        id: overviewDragHandle
        z: 1
        direction: Direction.Upwards
        distanceThreshold: units.gu(20)
        // TODO this needs to be disabled in a few more cases
        enabled: !overviewController.accepted || dragging

        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: units.gu(2)

        onSceneDistanceChanged: {
            overviewController.enableAnimation = false;
            overviewController.progress = Math.max(0, Math.min(1, sceneDistance / distanceThreshold));
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
