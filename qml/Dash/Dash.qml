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
        property bool growingDashFromAll: false
        Behavior on progress {
            id: progressAnimation
            UbuntuNumberAnimation { }
        }
    }

    ScopesOverview {
        id: scopesOverview
        anchors.fill: parent
        scope: scopes ? scopes.getScope("scopesOverview") : null
        enabled: !overviewController.showingNonFavoriteScope
        progress: overviewController.progress
        scopeScale: 1 - overviewController.progress * 0.6
        visible: scopeScale != 1
        currentIndex: dashContent.currentIndex
        onDone: {
            if (dashContent.parent == scopesOverviewXYScaler) {
                // Animate Dash growing from the All screen
                // TODO find where the thing comes from for that x, y
                scopesOverviewXYScaler.scale = scopesOverview.allCardSize.width / scopesOverviewXYScaler.width;
                scopesOverviewXYScaler.x = /*scopesOverview.allScopeClickedPos.x*/ -(scopesOverviewXYScaler.width - scopesOverviewXYScaler.width * scopesOverviewXYScaler.scale) / 2;
                scopesOverviewXYScaler.y = /*scopesOverview.allScopeClickedPos.y*/ -(scopesOverviewXYScaler.height - scopesOverviewXYScaler.height * scopesOverviewXYScaler.scale) / 2;
                overviewController.growingDashFromAll = true;
                scopesOverviewXYScaler.scale = 1;
                scopesOverviewXYScaler.x = 0;
                scopesOverviewXYScaler.y = 0;
            }
            hide();
        }
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
                scopeItem.parent = scopesOverviewXYScaler;
                scopesOverviewXYScaler.scale = scopesOverview.allCardSize.width / scopesOverviewXYScaler.width;
                scopesOverviewXYScaler.x = scopesOverview.allScopeClickedPos.x -(scopesOverviewXYScaler.width - scopesOverviewXYScaler.width * scopesOverviewXYScaler.scale) / 2;
                scopesOverviewXYScaler.y = scopesOverview.allScopeClickedPos.y -(scopesOverviewXYScaler.height - scopesOverviewXYScaler.height * scopesOverviewXYScaler.scale) / 2;
                overviewController.showingNonFavoriteScope = true;
                scopesOverview.overrideOpacity = 0;
                scopesOverviewXYScaler.scale = 1;
                scopesOverviewXYScaler.x = 0;
                scopesOverviewXYScaler.y = 0;
            }
        }
    }

    DashContent {
        id: dashContent
        parent: {
            if (overviewController.progress == 0) {
                return dash;
            } else if (scopesOverview.dashItemEater) {
                return scopesOverview.dashItemEater;
            } else {
                return scopesOverviewXYScaler;
            }
        }
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
        opacity: overviewController.growingDashFromAll ? 1 : 1 - overviewController.progress
    }

    DashBackground
    {
        anchors.fill: scopeItem
        visible: scopeItem.visible
        parent: scopeItem.parent
    }

    GenericScopeView {
        id: scopeItem

        // TODO test this width + dashContent.x still works
        x: overviewController.showingNonFavoriteScope ? 0 : width + dashContent.x
        z: 1
        width: parent.width
        height: parent.height
        scale: dash.contentScale
        clip: scale != 1.0
        visible:  scope != null
        hasBackAction: true
        isCurrent: visible
        onBackClicked: {
            if (overviewController.showingNonFavoriteScope) {
                var v = scopesOverview.allCardSize.width / scopeItem.width;
                scopesOverviewXYScaler.scale = v;
                scopesOverviewXYScaler.x = scopesOverview.allScopeClickedPos.x -(scopeItem.width - scopeItem.width * v) / 2;
                scopesOverviewXYScaler.y = scopesOverview.allScopeClickedPos.y -(scopeItem.height - scopeItem.height * v) / 2;
                scopesOverview.overrideOpacity = -1;
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

    Item {
        id: scopesOverviewXYScaler
        width: parent.width
        height: parent.height

        clip: scale != 1.0
        enabled: scale == 1
        opacity: scale

        property bool animationsEnabled: overviewController.showingNonFavoriteScope || overviewController.growingDashFromAll

        Behavior on x {
            enabled: scopesOverviewXYScaler.animationsEnabled
            UbuntuNumberAnimation { }
        }
        Behavior on y {
            enabled: scopesOverviewXYScaler.animationsEnabled
            UbuntuNumberAnimation { }
        }

        Behavior on scale {
            enabled: scopesOverviewXYScaler.animationsEnabled
            UbuntuNumberAnimation {
                onRunningChanged: {
                    if (!running) {
                        if (overviewController.showingNonFavoriteScope && scopesOverviewXYScaler.scale != 1) {
                            scopesOverview.scope.closeScope(scopeItem.scope);
                            overviewController.showingNonFavoriteScope = false;
                            scopeItem.scope = null;
                            scopeItem.parent = dash;
                        } else if (overviewController.growingDashFromAll) {
                            overviewController.growingDashFromAll = false;
                        }
                    }
                }
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
