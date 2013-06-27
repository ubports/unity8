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
      This is a read-only property with the action current value
     */
    property variant value : undefined

    /*!
      \preliminary
      The component which will have the property changed by action
     */
    property alias target: propertyBinding.target

    /*!
      \preliminary
      The property name of \l target component which will be linked with action state
     */
    property alias property: propertyBinding.property

    /*!
      \preliminary
      Use this to enable or disable the action state propagation to component property.
     */
    property bool active: true

    Component.onCompleted: connectViewChanges ()
    onTargetChanged: connectViewChanges()
    onPropertyChanged: connectViewChanges()

    Item {
        id: priv
        property variant actionObject : action!="" && actionGroup ? actionGroup.action(action) : null
        property variant actionState: actionObject ? actionObject.state : undefined

        Binding {
            id: propertyBinding
            value: priv.actionState
            when: (actionGroup && active && priv.actionObject)
        }
    }

    function connectViewChanges() {
        if (target && property) {
            var signalName = "on%1Changed".arg(property.charAt(0).toUpperCase() + property.slice(1));
            target[signalName].connect(onViewValueChanged);
        }
    }

    function onViewValueChanged() {
        if (priv.actionObject.valid) {
            var propertyValue = target[property];
            priv.actionObject.updateState(propertyValue);
        }
    }
}
