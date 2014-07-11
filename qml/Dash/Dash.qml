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
        property bool enableAnimation: false
        property real progress: 0
    }

    ScopesOverview {
        id: scopesOverview
        anchors.fill: parent
        scope: scopes ? scopes.getScope("scopesOverview") : null
        progress: overviewController.progress
        scopeScale: dashContent.scale
        visible: scopeScale != 1
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
                scopesOverview.hide();
                dashContent.x = -dashContent.width; // TODO
            }
        }
    }

    DashContent {
        id: dashContent
        objectName: "dashContent"
        width: parent.width
        height: parent.height
        model: filteredScopes
        scopes: scopes
        visible: x != -width
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
        scale: dash.contentScale * (1 - overviewController.progress * 0.6)
        clip: scale != 1.0 || scopeItem.visible
        Behavior on x {
            UbuntuNumberAnimation {
                onRunningChanged: {
                    if (!running && dashContent.x == 0) {
                        // TODO If it came from ScopesOverview it has to be ScopesOverview.scope.closeScope()
                        dashContent.closeScope(scopeItem.scope);
                        scopeItem.scope = null;
                    }
                }
            }
        }

        enabled: scale == 1
        opacity: 1 - overviewController.progress
        Behavior on scale {
            id: dashContentScaleAnimation
            enabled: overviewController.enableAnimation
            UbuntuNumberAnimation { }
        }
    }

    Image {
        anchors.fill: scopeItem
        source: parent.width > parent.height ? "graphics/paper_landscape.png" : "graphics/paper_portrait.png"
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignRight
        verticalAlignment: Image.AlignTop
    }

    GenericScopeView {
        id: scopeItem
        anchors.left: dashContent.right
        width: parent.width
        height: parent.height
        scale: dash.contentScale
        clip: scale != 1.0
        visible: scope != null
        hasBackAction: true
        isCurrent: visible
        onBackClicked: {
            // TODO if coming from dash overview this needs to go to overview
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
        direction: Direction.Upwards
        distanceThreshold: units.gu(20)
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
