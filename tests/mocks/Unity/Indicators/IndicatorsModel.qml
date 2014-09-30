/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Unity.Indicators 0.1 as Indicators

Indicators.FakeIndicatorsModel {
    id: root

    Component.onCompleted: {
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake1",
                                           "/com/canonical/indicators/fake1",
                                           "/com/canonical/indicators/fake1",
                                           {
                                               "title": "Bluetooth (F)",
                                               "icons": [ "image://theme/bluetooth-active" ],
                                           },
                                           getUnityMenuModelData("fake-indicator-bluetooth"));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake2",
                                           "/com/canonical/indicators/fake2",
                                           "/com/canonical/indicators/fake2",
                                           {
                                               "title": "Network (F)",
                                               "icons": [ "image://theme/simcard-error", "image://theme/wifi-high" ],
                                           },
                                           getUnityMenuModelData("fake-indicator-network"));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake3",
                                           "/com/canonical/indicators/fake3",
                                           "/com/canonical/indicators/fake3",
                                           {
                                               "title": "Messages (F)",
                                               "icons": [ "image://theme/messages-new" ],
                                           },
                                           getUnityMenuModelData("fake-indicator-sound"));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake4",
                                           "/com/canonical/indicators/fake4",
                                           "/com/canonical/indicators/fake4",
                                           {
                                               "title": "Sound (F)",
                                               "icons": [ "image://theme/audio-volume-high" ],
                                           },
                                           getUnityMenuModelData("fake-indicator-power"));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake5",
                                           "/com/canonical/indicators/fake5",
                                           "/com/canonical/indicators/fake5",
                                            {
                                                "title": "Battery (F)",
                                                "icons": [ "image://theme/battery-020" ],
                                            },
                                            getUnityMenuModelData("fake-indicator-bluetooth"));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake6",
                                           "/com/canonical/indicators/fake6",
                                           "/com/canonical/indicators/fake6",
                                           {
                                               "title": "Upcoming Events (F)",
                                               "label": "12:04",
                                           },
                                           getUnityMenuModelData("fake-indicator-datetime"));
    }

    function getUnityMenuModelData(identifier) {
        var root = [{
            "rowData": {                // 1
                "label": "root",
                "sensitive": true,
                "isSeparator": false,
                "icon": "",
                "type": "com.canonical.indicator.root",
                "ext": {},
                "action": "",
                "actionState": {},
                "isCheck": false,
                "isRadio": false,
                "isToggled": false,
            },
            "submenu": []
        }];

        var submenus = [];
        for (var i = 0; i < 8; i++) {
            var submenu = {
                "rowData": {                 // 1.1
                    "label": identifier,
                    "sensitive": true,
                    "isSeparator": false,
                    "icon": "",
                    "type": undefined,
                    "ext": {},
                    "action": "",
                    "actionState": {},
                    "isCheck": false,
                    "isRadio": false,
                    "isToggled": false,
            }};
            submenus.push(submenu);
        }
        root[0]["submenu"] = submenus;

        return root;
    }

    property var originalModelData: [
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
            "identifier": "fake-indicator-messages",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake3",
                "menuObjectPath": "/com/canonical/indicators/fake3",
                "actionsObjectPath": "/com/canonical/indicators/fake3"
            }
        },
        {
            "identifier": "fake-indicator-sound",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake4",
                "menuObjectPath": "/com/canonical/indicators/fake4",
                "actionsObjectPath": "/com/canonical/indicators/fake4"
            }
        },
        {
            "identifier": "fake-indicator-power",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake5",
                "menuObjectPath": "/com/canonical/indicators/fake5",
                "actionsObjectPath": "/com/canonical/indicators/fake5"
            }
        },
        {
            "identifier": "fake-indicator-datetime",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake6",
                "menuObjectPath": "/com/canonical/indicators/fake6",
                "actionsObjectPath": "/com/canonical/indicators/fake6"
            }
        }
    ]

    function load(profile) {
        unload();
        root.modelData = originalModelData;
    }
}
