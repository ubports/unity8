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

    property bool checked: false
    property bool secure: false
    property bool adHoc: false
    property int signalStrength: 0

    signal activate()

    onCheckedChanged: {
        // Can't rely on binding. Checked is assigned on click.
        checkBoxActive.checked = checked;
    }

    icon: {
        var imageName = "nm-signal-100"

        if (adHoc) {
            imageName = "nm-adhoc";
        } else if (signalStrength == 0) {
            imageName = "nm-signal-00";
        } else if (signalStrength <= 25) {
            imageName = "nm-signal-25";
        } else if (signalStrength <= 50) {
            imageName = "nm-signal-50";
        } else if (signalStrength <= 75) {
            imageName = "nm-signal-75";
        }

        if (secure) {
            imageName += "-secure";
        }
        return "image://theme/" + imageName;
    }

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
