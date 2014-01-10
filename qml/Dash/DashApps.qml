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
import Utils 0.1
import Unity.Application 0.1
import "../Components"
import "../Components/ListItems"
import "Apps"

GenericScopeView {
    id: scopeView
    objectName: "DashApps"

    ListModel {
        id: dummyVisibilityModifier

        ListElement { name: "running-apps" }
    }

    SortFilterProxyModel {
        id: runningApplicationsModel

        property bool canEnableTerminationMode: scopeView.isCurrent

        model: ApplicationManager
        filterRole: 0
        filterRegExp: invertMatch ? (ApplicationManager.count === 0 ? RegExp("running-apps") : RegExp("")) : RegExp("disabled")
        invertMatch: scopeView.scope.searchQuery.length == 0
    }

    onScopeChanged: {
        scopeView.scope.categories.overrideResults("recent", runningApplicationsModel);
        enableHeightBehaviorOnNextCreation = ApplicationManager.count === 0
    }
}
