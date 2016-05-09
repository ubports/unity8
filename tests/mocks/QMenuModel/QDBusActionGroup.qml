/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import QMenuModel 0.1

QtObject {
    id: actionGroup
    property int busType
    property string busName
    property string objectPath
    property var actions: ActionData ? ActionData.data : undefined

    signal dataChanged

    function start() {}

    function action(actionName) {
        return Qt.createQmlObject("
            import QtQuick 2.4
            import QMenuModel 0.1

            QtObject {
                signal activated

                property string actionName: \"" + actionName + "\"
                property bool valid: ActionData.data.hasOwnProperty(actionName) ? ActionData.data[actionName].valid : false
                property var state: ActionData.data.hasOwnProperty(actionName) ? ActionData.data[actionName].state : undefined

                function activate() {
                    activated();
                }

                function updateState(newState) {
                    state = newState;
                }
            }", actionGroup);
    }
}
