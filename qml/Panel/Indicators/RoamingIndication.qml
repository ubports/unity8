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
import QtQuick.Layouts 1.1

import Ubuntu.Components 0.1

RowLayout {
    spacing: units.gu(0.5)
    Label {
        id: labelRoaming
        elide: Text.ElideRight
        fontSize: "x-small"
        text: i18n.tr("Roaming")
        opacity: 0.6
    }

    Icon {
        id: iconRoaming
        color: Theme.palette.selected.backgroundText

        height: parent.height
        width: height

        name: "network-cellular-roaming"
    }
}
