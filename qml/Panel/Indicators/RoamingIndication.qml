/*
 * Copyright 2014,2015 Canonical Ltd.
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
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

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
        color: theme.palette.selected.backgroundText

        Layout.preferredHeight: parent.height
        Layout.preferredWidth: Layout.preferredHeight

        name: "network-cellular-roaming"
    }
}
