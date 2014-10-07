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
                                           getUnityMenuModelData("fake-indicator-bluetooth",
                                                                 "Bluetooth (F)",
                                                                 "",
                                                                 [ "image://theme/bluetooth-active" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake2",
                                           "/com/canonical/indicators/fake2",
                                           "/com/canonical/indicators/fake2",
                                           getUnityMenuModelData("fake-indicator-network",
                                                                 "Network (F)",
                                                                 "",
                                                                 [ "image://theme/simcard-error", "image://theme/wifi-high" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake3",
                                           "/com/canonical/indicators/fake3",
                                           "/com/canonical/indicators/fake3",
                                           getUnityMenuModelData("fake-indicator-sound",
                                                                 "Messages (F)",
                                                                 "",
                                                                 [ "image://theme/messages-new" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake4",
                                           "/com/canonical/indicators/fake4",
                                           "/com/canonical/indicators/fake4",
                                           getUnityMenuModelData("fake-indicator-power",
                                                                 "Sound (F)",
                                                                 "",
                                                                 [ "image://theme/audio-volume-high" ]));
        Indicators.UnityMenuModelCache.setCachedModelData("com.canonical.indicators.fake5",
                                           "/com/canonical/indicators/fake5",
                                           "/com/canonical/indicators/fake5",
                                           getUnityMenuModelData("fake-indicator-power",
                                                                 "Battery (F)",
                                                                 "",
                                                                 [ "image://theme/battery-020" ]));
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
                    "icons": icons
                },
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
            "identifier": "fake-indicator-1",
            "widgetSource": "Indicators/DefaultIndicatorWidget.qml",
            "pageSource": "Indicators/DefaultIndicatorPage.qml",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake1",
                "menuObjectPath": "/com/canonical/indicators/fake1",
                "actionsObjectPath": "/com/canonical/indicators/fake1"
            }
        },
        {
            "identifier": "fake-indicator-2",
            "widgetSource": "Indicators/DefaultIndicatorWidget.qml",
            "pageSource": "Indicators/DefaultIndicatorPage.qml",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake2",
                "menuObjectPath": "/com/canonical/indicators/fake2",
                "actionsObjectPath": "/com/canonical/indicators/fake2"
            }
        },
        {
            "identifier": "fake-indicator-3",
            "widgetSource": "Indicators/DefaultIndicatorWidget.qml",
            "pageSource": "Indicators/DefaultIndicatorPage.qml",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake3",
                "menuObjectPath": "/com/canonical/indicators/fake3",
                "actionsObjectPath": "/com/canonical/indicators/fake3"
            }
        },
        {
            "identifier": "fake-indicator-4",
            "widgetSource": "Indicators/DefaultIndicatorWidget.qml",
            "pageSource": "Indicators/DefaultIndicatorPage.qml",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake4",
                "menuObjectPath": "/com/canonical/indicators/fake4",
                "actionsObjectPath": "/com/canonical/indicators/fake4"
            }
        },
        {
            "identifier": "fake-indicator-5",
            "widgetSource": "Indicators/DefaultIndicatorWidget.qml",
            "pageSource": "Indicators/DefaultIndicatorPage.qml",
            "indicatorProperties": {
                "enabled": true,
                "busName": "com.canonical.indicators.fake5",
                "menuObjectPath": "/com/canonical/indicators/fake5",
                "actionsObjectPath": "/com/canonical/indicators/fake5"
            }
        }
    ]

    function load(profile) {
        unload();
        root.modelData = originalModelData;
    }
}
