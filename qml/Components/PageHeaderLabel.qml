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

PageHeader {
    property alias text: label.text

    childItem: Label {
        id: label
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        color: Theme.palette.selected.backgroundText
        opacity: 0.8
        font.family: "Ubuntu"
        font.weight: Font.Light
        fontSize: "x-large"
        elide: Text.ElideRight
        style: Text.Raised
        styleColor: "black"
    }
}
