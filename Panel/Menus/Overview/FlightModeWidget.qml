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
import Ubuntu.Components 0.1

Item {
    id: flightModeWidget

    Image {
        id: flightIcon
        source: "graphics/plane_icon.png"
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(4)
        height: units.gu(4)
    }

    Label {
        anchors {
            left: flightIcon.right
            right: flightModeSwitch.left
            margins: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        text: i18n.tr("Flight mode")
        color: Theme.palette.selected.backgroundText
        style: Text.Raised
        styleColor: "black"
        opacity: 0.6;
        fontSize: "medium"
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
    }

    Switch {
        id: flightModeSwitch
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
    }
}
