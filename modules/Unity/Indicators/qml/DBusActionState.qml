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
    \qmltype DBusActionState
    \inqmlmodule Indicators 0.1
    \brief Helper class to connect dbus action state with qml components property

    Exampiles:
    \qml
        Slider {
            id: slide
        }
        DBusActionState {
            actionGroup: menuItem.actionGroup
            action: "/ubuntu/sound/volume"
            target: slider
            property: "value"
        }
    \endqml

    \b{This component is under heavy development.}
*/

Item {
    id: dbusActionState

    /*!
      \preliminary
      The dbus action name
     */
    property string action : ""

    /*!
      \preliminary
      The dbus action group object
     */
    property QtObject actionGroup : null

    /*!
      \preliminary
      This is a read-only property with the action current value
     */
    property var value : undefined

    /*!
      \preliminary
      The component which will have the property changed by action
     */
    property alias target: propertyBinding.target

    /*!
      \preliminary
      The property name of \l target component which will be linked with action state
     */
    property string property: propertyBinding.property

    /*!
      \preliminary
      Use this to enable or disable the action state propagation to component property.
     */
    property bool active: true

    Component.onCompleted: connectViewChanges()
    onTargetChanged: connectViewChanges()
    onPropertyChanged: connectViewChanges()

    Item {
        id: priv
        property var actionObject: action != ""  && dbusActionState.actionGroup ? dbusActionState.actionGroup.action(action) : null
        property var actionState: actionObject ? actionObject.state : undefined

        property var currentTarget: undefined
        property string currentSignal

        Binding {
            id: propertyBinding
            value: priv.actionState
            when: (actionGroup && active && priv.actionObject)
            property: dbusActionState.property
        }
    }

    function connectViewChanges() {
        if (priv.currentTarget != undefined && priv.currentSignal !== "") {
            if (priv.currentTarget[priv.currentSignal] != undefined) {
                priv.currentTarget[priv.currentSignal].disconnect(onViewValueChanged);
            }
        }

        priv.currentTarget = null;
        priv.currentSignal = "";
        if (target) {
            var signal = "on%1Changed".arg(property.charAt(0).toUpperCase() + property.slice(1));
            if (target[signal] != undefined) {
                target[signal].connect(onViewValueChanged);
                priv.currentTarget = target;
                priv.currentSignal = signal;
            }
        }
    }

    function onViewValueChanged() {
        if (priv.actionObject.valid) {
            var propertyValue = target[property];
            priv.actionObject.updateState(propertyValue);
        }
    }
}
