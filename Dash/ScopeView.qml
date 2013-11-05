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
import Utils 0.1
import Unity 0.1
import "../Components"

FocusScope {
    property Scope scope
    property SortFilterProxyModel categories: categoryFilter
    property bool isCurrent
    property bool moving: false
    property int tabBarHeight: 0
    property PageHeader pageHeader: null
    property OpenEffect openEffect: null
    property Item previewListView: null

    signal endReached
    signal movementStarted
    signal positionedAtBeginning
    signal headerPositionChanged(int position)
    signal headerHeightChanged(int height)

    // FIXME delay the search so that daemons have time to settle, note that
    // removing this will break ScopeView::test_changeScope
    onScopeChanged: {
        if (scope) {
            timer.restart();
            scope.activateApplication.connect(activateApp);
        }
    }

    function activateApp(desktopFilePath) {
        shell.activateApplication(desktopFilePath);
    }

    Binding {
        target: scope
        property: "isActive"
        value: isCurrent
    }

    Timer {
        id: timer
        interval: 2000
        onTriggered: scope.searchQuery = ""
    }

    SortFilterProxyModel {
        id: categoryFilter
        model: scope ? scope.categories : null
        dynamicSortFilter: true
        filterRole: Categories.RoleCount
        filterRegExp: /^0$/
        invertMatch: true
    }
}
