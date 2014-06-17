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
            tabBarHeight: scopeItemPageHeader.implicitHeight
            pageHeader: scopeItemPageHeader
            previewListView: previewListView

            Connections {
                target: scopeView.isCurrent ? scope : null
                onGotoScope: root.gotoScope(scopeId);
                onOpenScope: root.openScope(scope);
            }
        }

        PageHeader {
            id: scopeItemPageHeader
            width: parent.width
            searchEntryEnabled: true
            searchHistory: root.searchHistory
            scope: root.scope
            height: units.gu(8.5)
            showBackButton: true
            onBackClicked: root.back();

            childItem: Label {
                id: label
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                text: scope ? scope.name : ""
                color: "#888888"
                font.family: "Ubuntu"
                font.weight: Font.Light
                fontSize: "x-large"
                elide: Text.ElideRight
            }

            afterLineChildItem: DashDepartments {
                scope: root.scope
                width: parent.width <= units.gu(60) ? parent.width : units.gu(40)
                anchors.right: parent.right
                windowHeight: root.height
                windowWidth: root.width
            }
        }
    }

    PreviewListView {
        id: previewListView
        visible: x != width
        pageHeader: scopeItemPageHeader
        scope: root.scope
        width: parent.width
        height: parent.height
        anchors.left: scopeViewHolder.right
    }
}
