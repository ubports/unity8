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

/*!
    \qmltype MenuAction
    \inqmlmodule Indicators 0.1
    \brief Helper class to connect to a qmenumodel action

    Example:
    \qml
        Button {
            id: slide
            onClick: { action.activate() }
        }
        MenuAction {
            id: action
            actionGroup: menuItem.actionGroup
            action: "/ubuntu/sound/enabled"
        }
    \endqml
*/

Item {
    id: menuAction

    /*!
      \preliminary
      The dbus action name
     */
    property string action: ""

    /*!
      \preliminary
      The dbus action group object
     */
    property QtObject actionGroup: null

    /*!
      \preliminary
      This is a read-only property with the current validity of the action
     */
    readonly property bool valid: actionObject ? actionObject.valid : false

    readonly property var state: actionObject ? actionObject.state : undefined

    // internal
    property QtObject actionObject: null

    function activate(param) {
        if (valid) {
            actionObject.activate(param);
        }
    }

    onActionGroupChanged: updateAction()
    onActionChanged: updateAction()

    Connections {
        target: menuAction.actionGroup != undefined ? menuAction.actionGroup : null
        onActionAppear: menuAction.updateAction();
        onActionVanish: menuAction.updateAction();
        onStatusChanged: menuAction.updateAction();
    }

    function updateAction() {
        actionObject = action !== "" && actionGroup ? actionGroup.action(action) : null
    }
}
