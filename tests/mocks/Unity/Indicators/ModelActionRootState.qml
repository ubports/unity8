/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.4

Item {
    property var menu: null
    property bool valid: cachedState !== undefined
    property string title: cachedState && cachedState.hasOwnProperty("title") ? cachedState["title"] : ""
    property string leftLabel: cachedState && cachedState.hasOwnProperty("pre-label") ? cachedState["pre-label"] : ""
    property string rightLabel: cachedState && cachedState.hasOwnProperty("label") ? cachedState["label"] : ""
    property var icons: cachedState && cachedState.hasOwnProperty("icons") ? cachedState["icons"] : []
    property string accessibleName: cachedState && cachedState.hasOwnProperty("accessible-desc") ? cachedState["accessible-desc"] : ""
    property bool indicatorVisible: cachedState && cachedState.hasOwnProperty("visible") ? cachedState["visible"] : true

    property var cachedState: menu ? menu.get(0, "actionState") : undefined
    Connections {
        target: menu
        onModelDataChanged: {
            cachedState = menu.get(0, "actionState");
        }
    }

    signal updated

    onValidChanged: updated()
    onTitleChanged: updated()
    onLeftLabelChanged: updated()
    onRightLabelChanged: updated()
    onIconsChanged: updated()
    onAccessibleNameChanged: updated()
    onIndicatorVisibleChanged: updated()
}
