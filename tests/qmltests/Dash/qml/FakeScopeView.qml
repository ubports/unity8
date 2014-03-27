/*
 * Copyright 2013 Canonical Ltd.
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
import Unity 0.2

import "../../../../qml/Dash"

GenericScopeView {
    id: fakeScopeView

    property alias backColor : back.color
    property var categoryView: null

    onMovementStarted: {
        if (shell != undefined && shell.scopeStatus != undefined) {
            shell.scopeStatus[scope.id].movementStarted++;
        }
    }
    onPositionedAtBeginning: {
        if (shell != undefined && shell.scopeStatus != undefined) {
            shell.scopeStatus[scope.id].positionedAtBeginning++;
        }
    }

    Rectangle {
        id: back
        anchors.fill: parent
        color: "grey"
        z: -1
    }
}
