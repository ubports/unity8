/*
 * Copyright 2014 Canonical Ltd.
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
import QtQuick.Layouts 1.1
import Lomiri.SelfTest 0.1 as UT
import Lomiri.Indicators 0.1 as Indicators
import Lomiri.Components 1.3
import Powerd 0.1
import Lights 0.1
import QMenuModel 0.1
import "../../../../qml/Panel/Indicators"

Item {
    id: root
    width: units.gu(30)
    height: units.gu(30)

    property var newMessage: {
        "messages" : {
            'valid': true,
            'state': {
                'icons': [ 'indicator-messages-new' ]
            }
        }
    };
    property var noNewMessage: {
        "messages" : {
            'valid': true,
            'state': {
                'icons': [ 'indicator-messages' ]
            }
        }
    };

    Component {
        id: light
        IndicatorsLight {}
    }

    Loader {
        id: loader
        sourceComponent: light
    }

    Component.onCompleted: {
        ActionData.data = newMessage;
        Powerd.setStatus(Powerd.On, Powerd.Unknown);
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                width: units.gu(4)
                height: width
                radius: width / 2
                anchors.centerIn: parent

                color: Lights.state === Lights.On ? Lights.color : "transparent"

                border.color: "black"
                border.width: 1
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false
            Layout.preferredWidth: units.gu(15)

            Button {
                Layout.fillWidth: true
                text: Powerd.status === Powerd.On ? "Power Off" : "Power On"
                onClicked: {
                    if (Powerd.status === Powerd.On) {
                        Powerd.setStatus(Powerd.Off, Powerd.Unknown);
                    } else {
                        Powerd.setStatus(Powerd.On, Powerd.Unknown);
                    }
                }
            }
        }
    }

    // come from Wizard Status plugin
    property var batteryIconNames: {
        "fullyCharged" : "fully-charged",
        "charging" :  "charging",
        "caution" : "caution",
        "empty" : "empty",
    }

    // come from DBUS com.canonical.indicator.power
    property var batteryLevelDBusSignals: {
        "80":  {"battery-level": {'valid': true, 'state': 80}},
        "100": {"battery-level": {'valid': true, 'state': 100}}
    }
    property var deviceStateDBusSignals: {
        "fullyCharged" : {'device-state': {'valid': true, 'state': "fully-charged"}},
        "charging"     : {'device-state': {'valid': true, 'state': "charging"}},
        "discharging"  : {'device-state': {'valid': true, 'state': "discharging"}}
    }

    property var combinedDBusSignals: {
        "hasMessageAndCharging" : {
             "messages" : {
                 'valid': true,
                 'state': {
                     'icons': [ 'indicator-messages-new' ]
                 }
             },
            'device-state': {'valid': true, 'state': "charging"}
        },
        "hasMessageAndFullyCharged" : {
            "messages" : {
                'valid': true,
                'state': {
                    'icons': [ 'indicator-messages-new' ]
                }
            },
            'device-state': {'valid': true, 'state': "fully-charged"}
        }
    }

    property color darkGreen: "darkgreen"
    property color green: "green"
    property color white: "white"
    property color orangeRed: "orangeRed"

    UT.LomiriTestCase {
        name: "IndicatorsLight"
        when: windowShown

        function init() {
            // reload
            ActionData.data = noNewMessage;
            loader.sourceComponent = undefined;
            loader.sourceComponent = light;
        }

        function test_LightsStatus_data() {
            return [
                //
                // new messages
                //
                { tag: "Powerd.On with No Message", powerd: Powerd.On, actionData: noNewMessage, expectedLightsState: Lights.Off },
                { tag: "Powerd.Off with No Message", powerd: Powerd.Off, actionData: noNewMessage, expectedLightsState: Lights.Off },
                { tag: "Powerd.On with New Message", powerd: Powerd.On, actionData: newMessage, expectedLightsState: Lights.Off },
                { tag: "Powerd.Off with New Message", powerd: Powerd.Off, actionData: newMessage, expectedLightsState: Lights.On },

                //
                // show charging
                //
                { tag: "Powerd.Off while charging",
                  expectedLightsState: Lights.On,
                      powerd: Powerd.Off, actionData: deviceStateDBusSignals.charging },

                { tag: "Powerd.On while charging",
                  expectedLightsState: Lights.Off,
                      powerd: Powerd.On, actionData: deviceStateDBusSignals.charging },

                { tag: "Powerd.On while charging",
                  expectedLightsState: Lights.Off,
                      powerd: Powerd.On, wizardStatus: batteryIconNames.charging },

                //
                // show charging and full
                //
                { tag: "Powerd.Off while charging and battery full",
                  expectedLightsState: Lights.On, expectedLightsColor: green,
                      powerd: Powerd.Off, actionData: deviceStateDBusSignals.fullyCharged },

                { tag: "Powerd.On while charging and battery full",
                  expectedLightsState: Lights.Off,
                      powerd: Powerd.On, actionData: deviceStateDBusSignals.fullyCharged },

                { tag: "Powerd.Off while discharging and battery full",
                  expectedLightsState: Lights.Off,
                      powerd: Powerd.Off, actionData: deviceStateDBusSignals.discharging, wizardStatus: batteryIconNames.fullyCharged },

                //
                // show empty
                //
                { tag: "Powerd.Off while discharging and battery empty",
                  expectedLightsState: Lights.On, expectedLightsColor: orangeRed,
                      powerd: Powerd.Off, wizardStatus: batteryIconNames.caution },

                { tag: "Powerd.On while discharging and battery empty",
                  expectedLightsState: Lights.Off,
                      powerd: Powerd.On, wizardStatus: batteryIconNames.caution },

                { tag: "Powerd.On while discharging and battery empty",
                  expectedLightsState: Lights.Off,
                      powerd: Powerd.On, wizardStatus: batteryIconNames.empty },

                { tag: "Powerd.Off while charging and battery empty",
                  expectedLightsState: Lights.On, expectedLightsColor: white,
                      powerd: Powerd.Off, actionData: deviceStateDBusSignals.charging },

                //
                // new message has highest priority
                //
                { tag: "Powerd.Off with New Message, discharging and battery empty",
                  expectedLightsState: Lights.On,
                  expectedLightsColor: darkGreen,
                  expectedLightsOnMillisec: 1000,
                  expectedLightsOffMillisec: 3000,
                      powerd: Powerd.Off, actionData: newMessage, wizardStatus: batteryIconNames.caution },

                { tag: "Powerd.Off with New Message and charging",
                  expectedLightsState: Lights.On,
                  expectedLightsColor: darkGreen,
                  expectedLightsOnMillisec: 1000,
                  expectedLightsOffMillisec: 3000,
                      powerd: Powerd.Off, actionData: combinedDBusSignals.hasMessageAndCharging },

                { tag: "Powerd.Off with New Message, charging and battery full",
                  expectedLightsState: Lights.On,
                  expectedLightsColor: darkGreen,
                  expectedLightsOnMillisec: 1000,
                  expectedLightsOffMillisec: 3000,
                      powerd: Powerd.Off, actionData: combinedDBusSignals.hasMessageAndFullyCharged },

                //
                // use battery level
                //
                { tag: "Powerd.Off while charging and battery level at 80%",
                  expectedLightsState: Lights.On, expectedLightsColor: white,
                      powerd: Powerd.Off, actionData: batteryLevelDBusSignals["80"], wizardStatus: batteryIconNames.charging },

                { tag: "Powerd.Off while charging and battery level at 100%",
                  expectedLightsState: Lights.On, expectedLightsColor: green,
                  expectedLightsOnMillisec: 1000,
                  expectedLightsOffMillisec: 0,
                      powerd: Powerd.Off, actionData: batteryLevelDBusSignals["100"], wizardStatus: batteryIconNames.charging },

                //
                // Support for Multicolor LED
                //
                { tag: "Powerd.Off with New Message & no support for multicolor led",
                  expectedLightsState: Lights.On,
                      powerd: Powerd.Off, actionData: newMessage, supportsMultiColorLed: false },
                { tag: "Powerd.Off while charging & support for multicolor led",
                  expectedLightsState: Lights.On,
                      powerd: Powerd.Off, actionData: deviceStateDBusSignals.charging, supportsMultiColorLed: true },
                { tag: "Powerd.Off while charging & no support for multicolor led",
                  expectedLightsState: Lights.Off,
                      powerd: Powerd.Off, actionData: deviceStateDBusSignals.charging, supportsMultiColorLed: false },
            ]
        }

        function test_LightsStatus(data) {
            console.log("----------------------------------------------------------------")

            if (data.hasOwnProperty("supportsMultiColorLed"))
                loader.item.supportsMultiColorLed = data.supportsMultiColorLed
            if (data.hasOwnProperty("powerd"))
                Powerd.setStatus(data.powerd, Powerd.Unknown)
            if (data.hasOwnProperty("actionData"))
                ActionData.data = data.actionData
            if (data.hasOwnProperty("wizardStatus"))
                loader.item.batteryIconName = data.wizardStatus

            compare(Lights.state, data.expectedLightsState, "Lights state does not match expected value");
            if (data.hasOwnProperty("expectedLightsColor"))
                compare(Lights.color, data.expectedLightsColor, "Lights color does not match expected value")
            if (data.hasOwnProperty("expectedLightsOnMillisec"))
                compare(Lights.onMillisec, data.expectedLightsOnMillisec, "Lights OnMillisec does not match expected value")
            if (data.hasOwnProperty("expectedLightsOffMillisec"))
                compare(Lights.offMillisec, data.expectedLightsOffMillisec, "Lights OffMillisec does not match expected value")
        }
    }
}
