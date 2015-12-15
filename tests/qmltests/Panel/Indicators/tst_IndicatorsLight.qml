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
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators
import Ubuntu.Components 1.3
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

    UT.UnityTestCase {
        name: "IndicatorsLight"
        when: windowShown

        function init() {
            // reload
            ActionData.data = noNewMessage;
            loader.sourceComponent = undefined;
            loader.sourceComponent = light;
            Powerd.setStatus(Powerd.On, Powerd.Unknown);
        }

        function test_LightsStatus_data() {
            return [
                { tag: "Powerd.On with No Message", powerd: Powerd.On, actionData: noNewMessage, expected: Lights.Off },
                { tag: "Powerd.Off with No Message", powerd: Powerd.Off, actionData: noNewMessage, expected: Lights.Off },
                { tag: "Powerd.On with New Message", powerd: Powerd.On, actionData: newMessage, expected: Lights.Off },
                { tag: "Powerd.Off with New Message", powerd: Powerd.Off, actionData: newMessage, expected: Lights.On },
            ]
        }

        function test_LightsStatus(data) {
            Powerd.setStatus(data.powerd, Powerd.Unknown);
            ActionData.data = data.actionData;

            compare(Lights.state, data.expected, "Light does not match expected value");
        }
    }
}
