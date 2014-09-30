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

import QtQuick 2.0

Item {
    property var menu: null
    property bool valid: true
    property string title: menu && menu.rootProperties.hasOwnProperty("title") ? menu.rootProperties["title"] : ""
    property string leftLabel: menu && menu.rootProperties.hasOwnProperty("pre-label") ? menu.rootProperties["pre-label"] : ""
    property string rightLabel: menu && menu.rootProperties.hasOwnProperty("label") ? menu.rootProperties["label"] : ""
    property var icons: menu && menu.rootProperties.hasOwnProperty("icons") ? menu.rootProperties["icons"] : []
    property string accessibleName: menu && menu.rootProperties.hasOwnProperty("accessible-desc") ? menu.rootProperties["accessible-desc"] : ""
    visible: menu && menu.rootProperties.hasOwnProperty("visible") ? menu.rootProperties["visible"] : true

    signal updated

    onValidChanged: updated()
    onTitleChanged: updated()
    onLeftLabelChanged: updated()
    onRightLabelChanged: updated()
    onIconsChanged: updated()
    onAccessibleNameChanged: updated()
    onVisibleChanged: updated()
}
