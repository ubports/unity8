/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import "../Components"

Item {
    id: root

    property alias scope: scopeView.scope
    property alias previewOpen: previewListView.open

    property ListModel searchHistory

    signal back
    signal gotoScope(string scopeId)
    signal openScope(var scope)

    // TODO see how much code we can share
    // between here and other Dash parts, it's starting to have
    // too much duplicated code with the DashDepartments, etc

    Item {
        id: scopeViewHolder

        x: previewListView.open ? -width : 0
        Behavior on x { UbuntuNumberAnimation { } }
        width: parent.width
        height: parent.height

        GenericScopeView {
            id: scopeView
            width: parent.width
            height: parent.height
            isCurrent: scope != null
            title: scope ? scope.name : ""
            hasBackAction: true
            searchHistory: root.searchHistory
            previewListView: previewListView

            onBackClicked: root.back();

            Connections {
                target: scopeView.isCurrent ? scope : null
                onGotoScope: root.gotoScope(scopeId);
                onOpenScope: root.openScope(scope);
            }
        }
    }

    PreviewListView {
        id: previewListView
        visible: x != width
        scope: root.scope
        width: parent.width
        height: parent.height
        anchors.left: scopeViewHolder.right
    }
}
