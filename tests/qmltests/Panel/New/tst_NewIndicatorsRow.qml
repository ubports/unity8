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
                                                   "title": "Upcoming Events",
                                                   "label": "12:04",
                                               });
    }

    Indicators.FakeIndicatorsModel {
        id: indicatorsModel

        indicatorData: [
            {
                "identifier": "indicator-fake1",
                "position": 0,
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake1",
                    "menuObjectPath": "/com/canonical/indicators/fake1",
                    "actionsObjectPath": "/com/canonical/indicators/fake1"
                }
            },
            {
                "identifier": "indicator-fake2",
                "position": 1,
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake2",
                    "menuObjectPath": "/com/canonical/indicators/fake2",
                    "actionsObjectPath": "/com/canonical/indicators/fake2"
                }
            },
            {
                "identifier": "indicator-fake3",
                "position": 2,
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake3",
                    "menuObjectPath": "/com/canonical/indicators/fake3",
                    "actionsObjectPath": "/com/canonical/indicators/fake3"
                }
            },
            {
                "identifier": "indicator-fake4",
                "position": 3,
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake4",
                    "menuObjectPath": "/com/canonical/indicators/fake4",
                    "actionsObjectPath": "/com/canonical/indicators/fake4"
                }
            },
            {
                "identifier": "indicator-fake5",
                "position": 4,
                "indicatorProperties": {
                    "enabled": true,
                    "busName": "com.canonical.indicators.fake5",
                    "menuObjectPath": "/com/canonical/indicators/fake5",
                    "actionsObjectPath": "/com/canonical/indicators/fake5"
                }
            }
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
            anchors.fill: indicatorsRow
        }

        IndicatorsRow {
            id: indicatorsRow
            overFlowWidth: units.gu(20)
            height: expanded ? units.gu(7) : units.gu(3)
            anchors.centerIn: parent
            indicatorsModel: indicatorsModel

            Behavior on height {NumberAnimation{duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing}}

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var item = indicatorsRow.indicatorAt(mouse.x, mouse.y);
                    indicatorsRow.currentItem = item;
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
        text: indicatorsRow.expanded ? "Collapse" : "Expand"
        onClicked: indicatorsRow.expanded = !indicatorsRow.expanded
    }

    UT.UnityTestCase {
        name: "IndicatorsRow"
    }
}
