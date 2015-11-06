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

import QtQuick 2.4
import Unity.Indicators 0.1 as Indicators

Indicators.FakeIndicatorsModel {
    id: root

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

        Indicators.UnityMenuModelCache.setCachedModelData("/com/canonical/indicators/fake1",
                                           getUnityMenuModelData("fake-indicator-bluetooth",
                                                                 "Bluetooth (F)",
                                                                 "",
                                                                 [ "image://theme/bluetooth-active" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("/com/canonical/indicators/fake2",
                                           getUnityMenuModelData("fake-indicator-network",
                                                                 "Network (F)",
                                                                 "",
                                                                 [ "image://theme/simcard-error", "image://theme/wifi-high" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("/com/canonical/indicators/fake3",
                                           getUnityMenuModelData("fake-indicator-messages",
                                                                 "Messages (F)",
                                                                 "",
                                                                 [ "image://theme/messages-new" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("/com/canonical/indicators/fake4",
                                           getUnityMenuModelData("fake-indicator-sound",
                                                                 "Sound (F)",
                                                                 "",
                                                                 [ "image://theme/audio-volume-high" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("/com/canonical/indicators/fake5",
                                           getUnityMenuModelData("fake-indicator-power",
                                                                 "Battery (F)",
                                                                 "",
                                                                 [ "image://theme/battery-020" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("/com/canonical/indicators/fake6",
                                           getUnityMenuModelData("fake-indicator-datetime",
                                                                 "Upcoming Events (F)",
                                                                 "12:04",
                                                                 []));
    }

    function getUnityMenuModelData(identifier, title, label, icons) {
        var root = [{
            "rowData": {                // 1
                "label": "",
                "sensitive": true,
                "isSeparator": false,
                "icon": "",
                "type": "com.canonical.indicator.root",
                "ext": {},
                "action": "",
                "actionState": {
                    "title": title,
                    "label": label,
                    "icons": icons,
                    "visible": true
                },
                "isCheck": false,
                "isRadio": false,
                "isToggled": false
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
                    "isToggled": false
            }};
            submenus.push(submenu);
        }
        root[0]["submenu"] = submenus;

        return root;
    }

    function setIndicatorVisible(identifier, visible) {
        for (var i = 0; i < originalModelData.length; i++) {
            if (originalModelData[i]["identifier"] === identifier) {
                var data = Indicators.UnityMenuModelCache.getCachedModelData(
                            originalModelData[i]["indicatorProperties"]["menuObjectPath"]);

                data[0]["rowData"]["actionState"]["visible"] = visible;

                Indicators.UnityMenuModelCache.setCachedModelData(
                            originalModelData[i]["indicatorProperties"]["menuObjectPath"],
                            data);
                break;
            }
        }

    }
}
