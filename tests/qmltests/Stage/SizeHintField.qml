/*
 * Copyright 2015 Canonical Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Row {
    property alias text: label.text
    property alias value: field.text
    spacing: units.gu(1)
    Label {
        id: label
        color: "black"; anchors.verticalCenter: parent.verticalCenter
    }
    TextField {
        id: field
        text: ""; width: units.gu(8); hasClearButton: false; maximumLength: 6; inputMask: "d00000"
    }
}
