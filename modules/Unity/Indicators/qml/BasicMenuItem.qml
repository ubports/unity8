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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Standard {
    id: _priv

    property bool menuActivated: false
    property QtObject menu
    property QtObject actionGroup
    property alias color: __bg.color

    signal activateMenu()
    signal deactivateMenu()

    showDivider: false
    __foregroundColor: "#e8e1d0"

    backgroundIndicator: RemoveBackground {
        state: _priv.swipingState
    }

    Rectangle {
        id: __bg

        anchors.fill: parent
        color: "#221e1c"
        z: -1
    }
}
