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

Indicators.BaseMenuItem {
    id: menuItem
    implicitHeight: units.gu(5.5)

    property bool checked: false
    property bool secure: false
    property bool adHoc: false
    property int signalStrength: 0
    property alias text: label.text

    signal activate()

    onCheckedChanged: {
        // Can't rely on binding. Checked is assigned on click.
        checkBoxActive.checked = checked;
    }

    onClicked: {
        checkBoxActive.clicked();
    }

    CheckBox {
        id: checkBoxActive
        height: units.gu(3)
        width: units.gu(3)

        anchors {
            left: parent.left
            leftMargin: menuItem.__contentsMargins
            verticalCenter: parent.verticalCenter
        }

        onClicked: {
            menuItem.activate();
        }
    }

    Image {
        id: iconSignal

        width: height
        height: Math.min(units.gu(5), parent.height - units.gu(1))
        anchors {
            left: checkBoxActive.right
            leftMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }

        source: {
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
            return "image://theme/" + imageName;
        }
    }

    Label {
        id: label
        anchors {
            left: iconSignal.right
            leftMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
            right: secureIcon.visible ? iconSecure.left : parent.right
            rightMargin: menuItem.__contentsMargins
        }
        elide: Text.ElideRight
        opacity: label.enabled ? 1.0 : 0.5
    }

    Image {
        id: iconSecure
        visible: secure
        source: "qrc:/indicators/artwork/network/secure.svg"

        width: height
        height: Math.min(units.gu(4), parent.height - units.gu(1))
        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
    }
}
