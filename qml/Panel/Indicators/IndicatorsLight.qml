/*
 * Copyright 2014 Canonical Ltd.
 * Copyright 2019 UBports Foundation
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
import Wizard 0.1

import "../../.."

QtObject {
    id: root

    property bool supportsMultiColorLed: true

    property string indicatorState: "INDICATOR_OFF"

    property color color: "darkgreen"
    property int onMillisec: 1000
    property int offMillisec: 3000

    property double batteryLevel: 0
    property string deviceState: ""
    property bool hasMessages: false

    property string batteryIconName: Status.batteryIcon
    property string displayStatus: Powerd.status

    onSupportsMultiColorLedChanged: {
        updateLightState("onSupportsMultiColorLedChanged")
    }

    onDisplayStatusChanged: {
        updateLightState("onDisplayStatusChanged")
    }

    onBatteryIconNameChanged: {
        updateLightState("onBatteryIconNameChanged")
    }

    function updateLightState(msg) {
        console.log("updateLightState: " + msg
            + ", indicatorState: " + indicatorState
            + ", supportsMultiColorLed: " + supportsMultiColorLed
            + ", hasMessages: " + hasMessages
            + ", icon: " + batteryIconName
            + ", displayStatus: " + displayStatus
            + ", deviceState: " + deviceState
            + ", batteryLevel: " + batteryLevel)

        //
        // priorities:
        //   unread messsages (highest), full&charging, charging, low
        //
        // Icons: (see device.s from indicator-power)
        //   %s-empty-symbolic             empty
        //   %s-caution-charging-symbolic  charging  [ 0..10)
        //   %s-low-charging-symbolic      charging  [10..30)
        //   %s-good-charging-symbolic     charging  [30..60)
        //   %s-full-charging-symbolic     charging  [60..100]
        //   %s-full-charged-symbolic      fully charged
        //   %s-low-symbolic               ?
        //   %s-full-symbolic              ?
        //
        // device-state: (see system-settings\plugins\battery)
        //   fully-charged
        //   charging
        //   discharging
        //
        // Indicators:
        //   unread notifications : darkgreen pulsing (1000/3000)
        //   charging             : white continuously
        //   battery full         : green  continuously
        //   battery low          : orangered pulsing (500/3000)
        //
        // Notes:
        //   Icon name 'full-charged' comes late (45m after 100%)
        //   so also check device-state and battery-level
        //
        //   Battery low warning dialog on screen shows up at 10%
        //   but 'caution' icon at 9%.
        //

        // only show led when display is off
        if (displayStatus == Powerd.On) {
            indicatorState = "INDICATOR_OFF"
            return
        }

        // unread messsages have highest priority
        if (hasMessages) {
            indicatorState = "HAS_MESSAGES"
            return
        }

        // if device does not support a multi color led set led off
        if(!supportsMultiColorLed) {
console.log("no support for Multicolor LED. " + indicatorState)
            indicatorState = "INDICATOR_OFF"
            return
        }

        var isCharging = batteryIconName.indexOf("charging") >= 0
                         || deviceState == "charging"
                         || deviceState == "fully-charged"

        var isFull = batteryIconName.indexOf("full-charged") >= 0
                     || deviceState == "fully-charged"
                     || batteryLevel >= 100

        if (isCharging && isFull) {
            indicatorState = "BATTERY_FULL"
        } else if (isCharging) {
            indicatorState = "BATTERY_CHARGING"
        } else if (batteryIconName.indexOf("caution") >= 0
                   || batteryIconName.indexOf("empty") >= 0) {
            indicatorState = "BATTERY_LOW"
        } else {
            indicatorState = "INDICATOR_OFF"
        }
    }

    onIndicatorStateChanged: {
        console.log("onIndicatorStateChange: " + indicatorState)

        switch (indicatorState) {
        case "INDICATOR_OFF":
            break;
        case "HAS_MESSAGES":
            color        = "darkgreen"
            onMillisec   = 1000
            offMillisec  = 3000
            break;
        case "BATTERY_FULL":
            color        = "green"
            onMillisec   = 1000
            offMillisec  = 0
            break;
        case "BATTERY_CHARGING":
            color        = "white"
            onMillisec   = 1000
            offMillisec  = 0
            break;
        case "BATTERY_LOW":
            color        = "orangered"
            onMillisec   = 500
            offMillisec  = 3000
            break;
        default:
            console.log("ERROR onIndicatorStateChange: unknown state: " + indicatorState)
            break;
        }

        // HACK: led is only updated after turn on so first always turn off
        Lights.state = Lights.Off
        if (indicatorState != "INDICATOR_OFF")
          Lights.state = Lights.On
    }

    // Existence of unread notifications is determined by checking for a specific icon name in a dbus signal.
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
        onHasMessagesChanged: {
            root.hasMessages = hasMessages
            updateLightState("onHasMessagesChanged")
        }
    }

    // Charging state and battery level are determined by listening to dbus signals from upower.
    // See also system-settings battery plugin.
    property var _ipag: QMenuModel.QDBusActionGroup {
        busType: 1
        busName: "com.canonical.indicator.power"
        objectPath: "/com/canonical/indicator/power"
        property variant batteryLevel: action("battery-level").state
        property variant deviceState: action("device-state").state
        Component.onCompleted: start()
        onBatteryLevelChanged: {
            root.batteryLevel = batteryLevel
            updateLightState("onBatteryLevelChanged")
        }
        onDeviceStateChanged: {
            root.deviceState = deviceState
            updateLightState("onDeviceStateChanged")
        }
    }

    Component.onCompleted: Lights.state = Lights.Off
    Component.onDestruction: Lights.state = Lights.Off

    property var _colorBinding: Binding {
        target: Lights
        property: "color"
        value: root.color
    }

    property var _onMillisecBinding: Binding {
        target: Lights
        property: "onMillisec"
        value: root.onMillisec
    }

    property var _offMillisecBinding: Binding {
        target: Lights
        property: "offMillisec"
        value: root.offMillisec
    }
}
