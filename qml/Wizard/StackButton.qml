/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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

import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: stackButton

    property string text

    property bool backArrow: false

    width: label.width
    height: label.height + units.gu(4)

    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        color: enabled ? theme.palette.normal.backgroundText : Qt.darker(theme.palette.normal.backgroundText, 1.5)
        text: {
            if (backArrow) {
                // Translators: This is the arrow for "Back" buttons
                return i18n.tr("〈  %1".arg(stackButton.text))
            } else {
                // Translators: This is the arrow for "Forward" buttons
                return i18n.tr("%1  〉".arg(stackButton.text))
            }
        }
        horizontalAlignment: backArrow ? Text.AlignLeft : Text.AlignRight
    }
}
