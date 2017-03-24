/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
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

// Meant to be created with a Loader to circumvent the "ChildWindowTree is instantiated recursively" error from the QML engine
Repeater {
    id: root
    property Item boundsItem
    delegate: ChildWindowTree {
        id: childWindowTree
        surface: model.surface
        z: root.count - model.index
        boundsItem: root.boundsItem
        Connections {
            target: childWindowTree.surface
            onFocusedChanged: {
                if (childWindowTree.surface.focused) {
                    childWindowTree.focus = true;
                    // focus the Loader
                    childWindowTree.parent.focus = true;
                }
            }
        }
    }
}
