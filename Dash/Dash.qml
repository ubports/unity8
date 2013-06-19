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
import Utils 0.1
import "../Components"

Showable {
    id: dash

    property alias contentProgress: dashContent.contentProgress
    property string showScopeOnLoaded: "home.scope"
    property real contentScale: 1.0

    width: units.gu(40)
    height: units.gu(71)

    function setCurrentScope(scopeId, animate, reset) {
        var scopeIndex = filteredScopes.findFirst(Scopes.RoleId, scopeId)

        if (scopeIndex == -1) {
            console.warn("No match for scope with id: %1".arg(scopeId))
            return
        }

        if (scopeIndex == dashContent.currentIndex && !reset) {
            // the scope is already the current one
            return
        }

        dashContent.setCurrentScopeAtIndex(scopeIndex, animate, reset)
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
        anchors.fill: parent
        model: filteredScopes
        scopes: scopes
        onMovementStarted: dashbar.startNavigation()
        onMovementEnded: dashbar.stopNavigation()
        onContentFlickStarted: dashbar.finishNavigation()
        onContentEndReached: dashbar.finishNavigation()
        onPreviewShown: dashbar.finishNavigation()
        onScopeLoaded: {
            if (scopeId == dash.showScopeOnLoaded) {
                dash.setCurrentScope(scopeId, false, false)
                dash.showScopeOnLoaded = ""
            }
        }
        scale: dash.contentScale
        clip: scale != 1.0
    }

    DashBar {
        id: dashbar
        objectName: "dashbar"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        model: filteredScopes
        currentIndex: dashContent.currentIndex
        onItemSelected: dashContent.setCurrentScopeAtIndex(index, true, false)
        opacity: dash.contentScale == 1.0 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { easing.type: Easing.OutQuad; duration: 150 } }
    }
}
