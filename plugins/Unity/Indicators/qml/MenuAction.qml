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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0

/*!
    \qmltype MenuAction
    \inqmlmodule Indicators 0.1
    \brief Helper class to connect to a qmenumodel action

    Example:
    \qml
        BaseMenuItem {
            id: menuItem

            Switch {
                checked: menuAction.state
            }

            Indicators.MenuAction {
                id: menuAction
                menu: menuItem.menu
            }
        }
    \endqml
*/

Item {
    id: menuAction

    /*!
      \preliminary
      The dbus action group object
     */
    readonly property string name: menu ? menu.action : ""

    property QtObject menu: null

    readonly property var state: menu ? menu.actionState : undefined

    readonly property bool active: menu ? menu.sensitive : false
}
