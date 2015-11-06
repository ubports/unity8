/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.4
import Powerd 0.1
import Lights 0.1
import QMenuModel 0.1 as QMenuModel
import Unity.Indicators 0.1 as Indicators

QtObject {
    id: root

    property color color: "darkgreen"

    property var _actionGroup: QMenuModel.QDBusActionGroup {
        busType: 1
        busName: "com.canonical.indicator.messages"
        objectPath: "/com/canonical/indicator/messages"
    }

    property var _rootState: Indicators.ActionRootState {
        actionGroup: _actionGroup
        actionName: "messages"
        Component.onCompleted: actionGroup.start()

        property bool hasMessages: valid && (String(icons).indexOf("indicator-messages-new") != -1)
    }

    Component.onDestruction: Lights.state = Lights.Off

    // QtObject does not have children
    property var _binding: Binding {
        target: Lights
        property: "state"
        value: {
            return (Powerd.status === Powerd.Off && _rootState.hasMessages) ? Lights.On : Lights.Off
        }
    }

    property var _colorBinding: Binding {
        target: Lights
        property: "color"
        value: root.color
    }
}
