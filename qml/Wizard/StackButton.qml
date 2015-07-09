/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.2

AbstractButton {
    id: stackButton

    property string text

    property bool backArrow: false

    width: label.width
    height: units.gu(5)

    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#525252"
        opacity: enabled ? 1.0 : 0.5
        font.weight: backArrow ? Font.Normal : Font.DemiBold
        text: stackButton.text
        horizontalAlignment: backArrow ? Text.AlignLeft : Text.AlignRight
    }
}
