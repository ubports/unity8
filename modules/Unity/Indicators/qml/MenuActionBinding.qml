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
    \qmltype MenuActionBinding
    \inqmlmodule Indicators 0.1
    \brief Helper class to connect a qmenumodel action state with a qml components property

    Example:
    \qml
        Slider {
            id: slide
        }
        MenuActionBinding {
            actionGroup: menuItem.actionGroup
            action: "/ubuntu/sound/volume"
            target: slider
            property: "value"
        }
    \endqml
*/

MenuAction {
    id: menuAction

    /*!
      \preliminary
      The component which will have the property changed by action
     */
    property QtObject target: null

    /*!
      \preliminary
      The property name of \l target component which will be linked with action state
     */
    property string property

    /*!
      \preliminary
      Use this to enable or disable the action state propagation to component property.
     */
    property bool active: true

    Component.onCompleted: connectViewChanges()
    onTargetChanged: connectViewChanges()
    onPropertyChanged: connectViewChanges()

    Item {
        id: d
        property var currentTarget: undefined
        property string currentSignal
    }

    Binding {
        id: propertyBinding
        target: menuAction.target
        property: menuAction.property
        value: menuAction.state
        when: menuAction.actionObject && menuAction.active
    }

    // TODO - re-evaluate in c++
    function connectViewChanges() {
        if (d.currentTarget != undefined && d.currentSignal !== "") {
            if (d.currentTarget[d.currentSignal] !== undefined) {
                d.currentTarget[d.currentSignal].disconnect(onViewValueChanged);
            }
        }

        d.currentTarget = null;
        d.currentSignal = "";
        if (target) {
            var signal = "on%1Changed".arg(property.charAt(0).toUpperCase() + property.slice(1));
            if (target[signal] !== undefined) {
                target[signal].connect(onViewValueChanged);
                d.currentTarget = target;
                d.currentSignal = signal;
            }
        }
    }

    function onViewValueChanged() {
        if (valid) {
            var propertyValue = target[property];
            actionObject.updateState(propertyValue);
        }
    }
}
