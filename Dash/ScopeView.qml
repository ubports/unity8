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

FocusScope {
    property Scope scope
    property SortFilterProxyModel categories: categoryFilter
    property bool isCurrent
    property ListModel searchHistory

    signal endReached
    signal movementStarted
    signal positionedAtBeginning

    // FIXME delay the search so that daemons have time to settle
    onScopeChanged: timer.restart()

    Connections {
        target: scope
        onActivateApplication: activateApp
    }

    function activateApp(desktopFilePath) {
        shell.activateApplication(desktopFilePath);
    }

    Timer {
        id: timer
        interval: 2000
        onTriggered: scope.searchQuery = ""
    }

    SortFilterProxyModel {
        id: categoryFilter
        model: scope.categories
        dynamicSortFilter: true
        filterRole: Categories.RoleCount
        filterRegExp: /^0$/
        invertMatch: true
    }
}
