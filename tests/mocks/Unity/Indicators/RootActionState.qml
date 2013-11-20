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

QtObject {
    property var menu
    property bool valid: false
    property string title
    property string leftLabel
    property string rightLabel
    property var icons
    property string accessibleName
    property bool visible: true

    signal updated

    onValidChanged: updated()
    onTitleChanged: updated()
    onLeftLabelChanged: updated()
    onRightLabelChanged: updated()
    onIconsChanged: updated()
    onAccessibleNameChanged: updated()
    onVisibleChanged: updated()
}
