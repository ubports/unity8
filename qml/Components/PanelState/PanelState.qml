/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

import QtQuick 2.4

QtObject {
    id: root

    property string title: ""
    property bool decorationsVisible: false
    property bool decorationsAlwaysVisible: false
    property bool closeButtonShown: true
    property bool dropShadow: false
    property int panelHeight: 0

    signal closeClicked()
    signal minimizeClicked()
    signal restoreClicked()

    property string focusedPersistentSurfaceId: ""
    property bool focusedSurfaceMaximized: false
}
