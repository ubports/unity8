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
import Unity 0.2
import Utils 0.1
import "../Components"

Showable {
    id: dash
    objectName: "dash"

    visible: shown

    property string showScopeOnLoaded: "clickscope"
    property real contentScale: 1.0

    property alias overviewHandleHeight: dashContent.overviewHandleHeight

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
        scale: dash.contentScale
        clip: scale != 1.0 || scopeItem.visible
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
}
