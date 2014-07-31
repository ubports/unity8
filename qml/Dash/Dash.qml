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
        }
        dynamicSortFilter: true

        filterRole: Scopes.RoleVisible
        filterRegExp: RegExp("^true$")
    }

    QtObject {
        id: overviewController
        objectName: "overviewController"

        property alias enableAnimation: progressAnimation.enabled
        property real progress: 0
        Behavior on progress {
            id: progressAnimation
            UbuntuNumberAnimation { }
        }
    }

    ScopesOverview {
        id: scopesOverview
        objectName: "scopesOverview"
        anchors.fill: parent
        scope: scopes.overviewScope
        progress: overviewController.progress
        scopeScale: scopeItem.scope ? 0.4 : (1 - overviewController.progress * 0.6)
        visible: scopeScale != 1
        currentIndex: dashContent.currentIndex
        onDone: {
            if (currentTab == 1) {
                animateDashFromAll(dashContent.currentScopeId);
            }
            hide();
        }
        onFavoriteSelected: {
            setCurrentScope(scopeId, false, false);
            dashContentCache.scheduleUpdate();
            hide();
        }
        onAllFavoriteSelected: {
            setCurrentScope(scopeId, false, false);
            dashContentCache.scheduleUpdate();
            animateDashFromAll(dashContent.currentScopeId);
            hide();
        }
        onSearchSelected: {
            var scopeIndex = filteredScopes.findFirst(Scopes.RoleId, scopeId);
            if (scopeIndex >= 0) {
                // Is a favorite one
                setCurrentScope(scopeId, false, false);
                dashContentCache.scheduleUpdate();
                showDashFromPos(pos, size);
                hide();
            } else {
                // Is not a favorite one, activate and get openScope
                scope.activate(result);
            }
        }
        function hide() {
            overviewController.enableAnimation = true;
            overviewController.progress = 0;
        }
        onProgressChanged: {
            if (progress == 0) {
                currentTab = scopeItem.scope ? 1 : 0;
            }
        }
    }

    ShaderEffectSource {
        id: dashContentCache
        parent: scopesOverview.dashItemEater
        z: 1
        sourceItem: dashContent
        height: sourceItem.height
        width: sourceItem.width
        opacity: 1 - overviewController.progress
        visible: overviewController.progress != 0
        live: false
    }

    DashContent {
        id: dashContent

        property var scopeThatOpenedScope: null

        objectName: "dashContent"
        width: dash.width
        height: dash.height
        model: filteredScopes
        scopes: scopes
        visible: !scopesOverview.showingNonFavoriteScope && x != -width
        onGotoScope: {
            dash.setCurrentScope(scopeId, true, false);
        }
        onOpenScope: {
            scopeThatOpenedScope = currentScope;
            scopeItem.scope = scope;
            scopesOverview.currentTab = 1;
            scopesOverview.ensureAllScopeVisible(scope.id);
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
                duration: overviewController.progress != 0 ? 0 : UbuntuAnimation.FastDuration
                onRunningChanged: {
                    if (!running && dashContent.x == 0) {
                        dashContent.scopeThatOpenedScope.closeScope(scopeItem.scope);
                        scopeItem.scope = null;
                        if (overviewController.progress == 0) {
                            // Set tab to Favorites only if we are not showing the overview
                            scopesOverview.currentTab = 0;
                        }
                    }
                }
            }
        }

        enabled: overviewController.progress == 0
        opacity: enabled ? 1 : 0
    }

    DashBackground
    {
        anchors.fill: scopeItem
        visible: scopeItem.visible
        parent: scopeItem.parent
        scale: scopeItem.scale
        opacity: scopeItem.opacity
    }

    GenericScopeView {
        id: scopeItem
        objectName: "dashTempScopeItem"

        readonly property real targetOverviewScale: {
            if (scopesOverview.currentTab == 0) {
                return 0.4;
            } else {
                return scopesOverview.allCardSize.width / scopeItem.width;
            }
        }
        readonly property real overviewProgressScale: (1 - overviewController.progress * (1 - targetOverviewScale))
        readonly property var targetOverviewPosition: scope ? scopesOverview.allScopeCardPosition(scope.id) : null
        readonly property real overviewProgressX: scope && scopesOverview.currentTab == 1 && targetOverviewPosition ?
                                                      overviewController.progress * (targetOverviewPosition.x - (width - scopesOverview.allCardSize.width) / 2)
                                                      : 0
        readonly property real overviewProgressY: scope && scopesOverview.currentTab == 1 && targetOverviewPosition ?
                                                      overviewController.progress * (targetOverviewPosition.y - (height - scopesOverview.allCardSize.height) / 2)
                                                      : 0

        x: overviewController.progress == 0 ? dashContent.x + width : overviewProgressX
        y: overviewController.progress == 0 ? dashContent.y : overviewProgressY
        width: parent.width
        height: parent.height
        scale: dash.contentScale * overviewProgressScale
        enabled: opacity == 1
        opacity: 1 - overviewController.progress
        clip: scale != 1.0
        visible: scope != null
        hasBackAction: true
        isCurrent: visible
        onBackClicked: {
            closeOverlayScope();
            closePreview();
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
        objectName: "overviewDragHandle"
        z: 1
        direction: Direction.Upwards
        enabled: !dashContent.previewShown &&
                  dashContent.currentScope &&
                  dashContent.currentScope.searchQuery == "" &&
                  (overviewController.progress == 0 || dragging)

        readonly property real fullMovement: units.gu(20)

        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: units.gu(2)

        onSceneDistanceChanged: {
            if (overviewController.enableAnimation) {
                dashContentCache.scheduleUpdate();
            }
            overviewController.enableAnimation = false;
            overviewController.progress = Math.max(0, Math.min(1, sceneDistance / fullMovement));
        }

        onDraggingChanged: {
            overviewController.enableAnimation = true;
            overviewController.progress = (overviewController.progress > 0.7)  ? 1 : 0;
        }
    }

}
