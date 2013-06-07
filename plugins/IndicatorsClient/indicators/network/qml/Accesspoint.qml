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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import IndicatorsClient 0.1 as IndicatorsClient

IndicatorsClient.Menu {
    property variant actionWifiApStrength : menu && actionGroup ? actionGroup.action(menu.extra.canonical_wifi_ap_strength_action) : null
    property variant wifiApStrength : actionWifiApStrength && actionWifiApStrength.valid ? actionWifiApStrength.state : "0"

    implicitHeight: units.gu(7)

    function getNetworkIcon(data) {
        var imageName = "nm-signal-100"
        var signalStrength = parseInt(wifiApStrength)

        if (data.extra.canonical_wifi_ap_is_adhoc) {
            imageName = "nm-adhoc"
        } else if (signalStrength == 0) {
            imageName = "nm-signal-00"
        } else if (signalStrength <= 25) {
            imageName = "nm-signal-25"
        } else if (signalStrength <= 50) {
            imageName = "nm-signal-50"
        } else if (signalStrength <= 75) {
            imageName = "nm-signal-75"
        }

        if (data.extra.canonical_wifi_ap_is_secure) {
            imageName += "-secure"
        }

        return "image://gicon/" + imageName;
    }

    icon: menu && wifiApStrength ? getNetworkIcon(menu) : "image://gicon/nm-no-connection"
    iconFrame: false
    control: CheckBox {
        id: checkBoxActive
        height: units.gu(4)
        width: units.gu(4)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    IndicatorsClient.DBusActionState {
        action: menu ? menu.action : undefined
        target: checkBoxActive
        property: "checked"
    }
}
