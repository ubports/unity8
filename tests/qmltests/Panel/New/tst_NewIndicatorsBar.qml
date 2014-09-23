/*
 * Copyright 2013 Canonical Ltd.
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtTest 1.0
import ".."
import "../../../../qml/Panel/New"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators

Rectangle {
    width: units.gu(100)
    height: units.gu(30)
    color: "white"

    Component.onCompleted: {
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake1",
                                                "/com/canonical/indicators/fake1",
                                                "/com/canonical/indicators/fake1",
                                                {
                                                    "title": "Bluetooth",
                                                    "icons": [ "image://theme/bluetooth-active" ],
                                                });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake2",
                                                "/com/canonical/indicators/fake2",
                                                "/com/canonical/indicators/fake2",
                                                {
                                                    "title": "Network",
                                                    "icons": [ "image://theme/simcard-error", "image://theme/wifi-high" ],
                                                });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake3",
                                                "/com/canonical/indicators/fake3",
                                                "/com/canonical/indicators/fake3",
                                                {
                                                    "title": "Sound",
                                                    "icons": [ "image://theme/audio-volume-high" ],
                                                });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake4",
                                                "/com/canonical/indicators/fake4",
                                                "/com/canonical/indicators/fake4",
                                                {
                                                    "title": "Battery",
                                                    "icons": [ "image://theme/battery-020" ],
                                                });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake5",
                                                "/com/canonical/indicators/fake5",
                                                "/com/canonical/indicators/fake5",
                                                {
                                                    "title": "Location",
                                                    "icons": [ "image://theme/gps" ],
                                                });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake6",
                                                "/com/canonical/indicators/fake6",
                                                "/com/canonical/indicators/fake6",
                                                {
                                                    "title": "Notifications",
                                                    "icons": [ "image://theme/messages-new" ],
                                                });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake7",
                                                "/com/canonical/indicators/fake7",
                                                "/com/canonical/indicators/fake7",
                                                {
                                                    "title": "Upcoming Events",
                                                    "label": "12:04",
                                                });
    }

    Indicators.FakeIndicatorsModel {
        id: indicatorsModel

        indicatorData: [
            {
                "identifier": "indicator-fake1",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake1",
                    "menuObjectPath": "/com/canonical/indicators/fake1",
                    "actionsObjectPath": "/com/canonical/indicators/fake1"
                }
            },
            {
                "identifier": "indicator-fake2",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake2",
                    "menuObjectPath": "/com/canonical/indicators/fake2",
                    "actionsObjectPath": "/com/canonical/indicators/fake2"
                }
            },
            {
                "identifier": "indicator-fake3",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake3",
                    "menuObjectPath": "/com/canonical/indicators/fake3",
                    "actionsObjectPath": "/com/canonical/indicators/fake3"
                }
            },
            {
                "identifier": "indicator-fake4",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake4",
                    "menuObjectPath": "/com/canonical/indicators/fake4",
                    "actionsObjectPath": "/com/canonical/indicators/fake4"
                }
            },
            {
                "identifier": "indicator-fake5",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake5",
                    "menuObjectPath": "/com/canonical/indicators/fake5",
                    "actionsObjectPath": "/com/canonical/indicators/fake5"
                }
            },
            {
                "identifier": "indicator-fake6",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake6",
                    "menuObjectPath": "/com/canonical/indicators/fake6",
                    "actionsObjectPath": "/com/canonical/indicators/fake6"
                }
            },
            {
                "identifier": "indicator-fake7",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake7",
                    "menuObjectPath": "/com/canonical/indicators/fake7",
                    "actionsObjectPath": "/com/canonical/indicators/fake7"
                }
            },
            {
                "identifier": "indicator-fake8",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake1",
                    "menuObjectPath": "/com/canonical/indicators/fake1",
                    "actionsObjectPath": "/com/canonical/indicators/fake1"
                }
            },
            {
                "identifier": "indicator-fake9",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake1",
                    "menuObjectPath": "/com/canonical/indicators/fake1",
                    "actionsObjectPath": "/com/canonical/indicators/fake1"
                }
            },
            {
                "identifier": "indicator-fake10",
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake1",
                    "menuObjectPath": "/com/canonical/indicators/fake1",
                    "actionsObjectPath": "/com/canonical/indicators/fake1"
                }
            },
        ]
    }

    Rectangle {
        id: itemArea
        color: "blue"
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: units.gu(50)

        Rectangle {
            color: "black"
            anchors.fill: indicatorsBar
        }

        IndicatorsBar {
            id: indicatorsBar
            height: expanded ? units.gu(7) : units.gu(3)
            width: units.gu(30)
            anchors.centerIn: parent
            indicatorsModel: indicatorsModel

            Behavior on height { NumberAnimation { duration: 1000; easing: UbuntuAnimation.StandardEasing } }

            MouseArea {
                anchors.fill: parent
                enabled: !indicatorsBar.expanded
                onPressed: {
                    console.log("click")
                    indicatorsBar.selectItemAt(mouse.x);
                    indicatorsBar.expanded = true
                }
            }
        }
    }

    ColumnLayout {
        anchors {
            top: parent.top
            bottom: button.top
            left: itemArea.right
            right: parent.right
        }
    }

    Button {
        id: button
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        text: indicatorsBar.expanded ? "Collapse" : "Expand"
        onClicked: indicatorsBar.expanded = !indicatorsBar.expanded
    }

    UT.UnityTestCase {
        name: "IndicatorsRow"
    }
}
