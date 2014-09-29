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
import "../../../../qml/Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators

Rectangle {
    id: root
    color: "white"

    Component.onCompleted: {
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake1",
                                               "/com/canonical/indicators/fake1",
                                               "/com/canonical/indicators/fake1",
                                               {
                                                   "title": "Bluetooth (F)",
                                                   "icons": [ "image://theme/bluetooth-active" ],
                                               });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake2",
                                               "/com/canonical/indicators/fake2",
                                               "/com/canonical/indicators/fake2",
                                               {
                                                   "title": "Network (F)",
                                                   "icons": [ "image://theme/simcard-error", "image://theme/wifi-high" ],
                                               });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake3",
                                               "/com/canonical/indicators/fake3",
                                               "/com/canonical/indicators/fake3",
                                               {
                                                   "title": "Sound (F)",
                                                   "icons": [ "image://theme/audio-volume-high" ],
                                               });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake4",
                                               "/com/canonical/indicators/fake4",
                                               "/com/canonical/indicators/fake4",
                                               {
                                                   "title": "Battery (F)",
                                                   "icons": [ "image://theme/battery-020" ],
                                               });
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake5",
                                               "/com/canonical/indicators/fake5",
                                               "/com/canonical/indicators/fake5",
                                               {
                                                   "title": "Upcoming Events (F)",
                                                   "label": "12:04",
                                               });
    }

    property var indicatorData: [
        {
            "identifier": "fake-indicator-bluetooth",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake1",
                "menuObjectPath": "/com/canonical/indicators/fake1",
                "actionsObjectPath": "/com/canonical/indicators/fake1"
            }
        },
        {
            "identifier": "fake-indicator-network",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake2",
                "menuObjectPath": "/com/canonical/indicators/fake2",
                "actionsObjectPath": "/com/canonical/indicators/fake2"
            }
        },
        {
            "identifier": "fake-indicator-sound",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake3",
                "menuObjectPath": "/com/canonical/indicators/fake3",
                "actionsObjectPath": "/com/canonical/indicators/fake3"
            }
        },
        {
            "identifier": "fake-indicator-battery",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake4",
                "menuObjectPath": "/com/canonical/indicators/fake4",
                "actionsObjectPath": "/com/canonical/indicators/fake4"
            }
        },
        {
            "identifier": "fake-indicator-datetime",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake5",
                "menuObjectPath": "/com/canonical/indicators/fake5",
                "actionsObjectPath": "/com/canonical/indicators/fake5"
            }
        }
    ]

    property alias indicatorsModel: __indicatorsModel
    Indicators.FakeIndicatorsModel {
        id: __indicatorsModel
        indicatorData: root.indicatorData
    }

    function insertIndicator(index) {
        var i;
        var insertIndex = 0;
        var done = false;
        for (i = index; !done && i >= 1; i--) {

            var lookFor = root.indicatorData[i-1]["identifier"]

            var j;
            for (j = indicatorsModel.indicatorData.length-1; !done && j >= 0; j--) {
                if (indicatorsModel.indicatorData[j]["identifier"] === lookFor) {
                    insertIndex = j+1;
                    done = true;
                }
            }
        }
        indicatorsModel.insert(insertIndex, root.indicatorData[index]);
    }

    function removeIndicator(index) {
        var i;
        for (i = 0; i < indicatorsModel.indicatorData.length; i++) {
            if (indicatorsModel.indicatorData[i]["identifier"] === root.indicatorData[index]["identifier"]) {
                indicatorsModel.remove(i);
                break;
            }
        }
    }

    function resetData() {
        indicatorsModel.indicatorData = root.indicatorData;
    }
}
