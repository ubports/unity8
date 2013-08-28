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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.IndicatorsLegacy 0.1 as Indicators

Indicators.IndicatorWidget {
    id: indicatorWidget

    width: networkIcon.width + units.gu(1)

    property int signalStrength: 0
    property int connectionState: Indicators.NetworkConnection.Initial
    rootMenuType: "com.canonical.indicator.root.network"

    // FIXME : Should us Ubuntu.Icon . results in low res images
    Image {
        id: networkIcon
        objectName: "itemImage"
        source: get_icon_for_signal(connectionState, signalStrength)
        visible: source != ""
        height: indicatorWidget.iconSize
        width: indicatorWidget.iconSize
        anchors.centerIn: parent
    }

    onActionStateChanged: {
        if (action == undefined || !action.valid) {
            return;
        }

        if (action.state == undefined) {
            connectionState = 0;
            return;
        }

        connectionState = action.state[Indicators.NetworkActionState.Connection];
        if (connectionState == Indicators.NetworkConnection.Activated) {
            signalStrength = action.state[Indicators.NetworkActionState.SignalStrength];
        }
    }

    NumberAnimation {
        id: activation_animation
        target: indicatorWidget
        property: "signalStrength"
        from: 0
        to: 100
        duration: 2500  // 5 states in 2.5 seconds
        loops: Animation.Infinite
    }

    states: [
        State {
            name: "unknown"
            when: connectionState < Indicators.NetworkConnection.Activating || connectionState > Indicators.NetworkConnection.Deactivating
            PropertyChanges { target: activation_animation; running: false }
        },
        State {
            name: "activating"
            when: connectionState == Indicators.NetworkConnection.Activating
            PropertyChanges { target: activation_animation; running: true }
        },
        State {
            name: "activated"
            when: connectionState == Indicators.NetworkConnection.Activated
            PropertyChanges { target: activation_animation; running: false }
        },
        State {
            name: "deactivating"
            when: connectionState == Indicators.NetworkConnection.Deactivating
            PropertyChanges { target: activation_animation; running: true }
        }
    ]


    function get_icon_for_signal(con_state, value) {
        if (con_state >= Indicators.NetworkConnection.Activating && con_state <= Indicators.NetworkConnection.Deactivating) {
            if (value == 0) {
                return "image://gicon/nm-signal-00";
            } else if (value <= 25) {
                return "image://gicon/nm-signal-25";
            } else if (value <= 50) {
                return "image://gicon/nm-signal-50";
            } else if (value <= 75) {
                return "image://gicon/nm-signal-75";
            }
            return "image://gicon/nm-signal-100";
        }
        return "image://gicon/wifi-none";
    }
}
