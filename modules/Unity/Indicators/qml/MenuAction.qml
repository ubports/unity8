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

QtObject {
    id: dbusAction

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
    readonly property bool valid: __actionObject ? __actionObject.valid : false

    readonly property var state: __actionObject ? __actionObject.state : undefined

    // internal
    property QtObject __actionObject: null

    function activate(param) {
        if (valid) {
            __actionObject.activate(param);
        }
    }

    onActionGroupChanged: updateAction()
    onActionChanged: updateAction()

    QtObject {
        id: priv
        property var actionObject: null

        Connections {
            target: dbusAction.actionGroup != undefined ? dbusAction.actionGroup : null
            onActionAppear: dbusAction.updateAction();
            onActionVanish: dbusAction.updateAction();
            onStatusChanged: dbusAction.updateAction();
        }
    }

    function updateAction() {
        __actionObject = action !== "" && actionGroup ? actionGroup.action(action) : null
    }
}
