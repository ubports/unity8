/*
 * Copyright 2014 Canonical Ltd.
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
 *      Antti Kaijanmäki <antti.kaijanmaki@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    width: (labelRoaming.width > iconRoaming.width) ? labelRoaming.width : iconRoaming.width

    Icon {
        id: iconRoaming
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        color: Theme.palette.selected.backgroundText
        keyColor: "#cccccc"

        width: height
        height: units.gu(4)

        name: "network-cellular-roaming"
    }

    Label {
        id: labelRoaming
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        elide: Text.ElideRight

        fontSize: "x-small"
        font.bold: true

        text: i18n.tr("roaming")
    }
}
