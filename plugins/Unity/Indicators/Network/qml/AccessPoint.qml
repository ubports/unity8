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
import Unity.Indicators 0.1 as Indicators

Indicators.FramedMenuItem {
    id: accessPoint

    readonly property bool checked: menu ? menu.isToggled : false

    onCheckedChanged: {
        // Can't rely on binding. Checked is assigned on click.
        checkBoxActive.checked = checked;
    }

    // FIXME - we need to get the strength from menu.ext.xCanonicalWifiApStrengthAction
    // but UnityMenuModel doesnt support fetching actions not attached to menu item.
    function getNetworkIcon(data) {
        var imageName = "nm-signal-100"

        if (data.ext.xCanonicalWifiApIsAdhoc) {
            imageName = "nm-adhoc";
        }
        if (data.ext.xCanonicalWifiApIsSecure) {
            imageName += "-secure";
        }

        return "image://gicon/" + imageName;
    }

    icon: menu ? getNetworkIcon(menu) : "image://gicon/wifi-none"
    iconFrame: false
    control: CheckBox {
        id: checkBoxActive
        height: units.gu(4)
        width: units.gu(4)
        anchors.centerIn: parent

        onClicked: {
            accessPoint.activate();
        }
    }
}
