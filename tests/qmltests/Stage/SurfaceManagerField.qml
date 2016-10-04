/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import Unity.Application 0.1

Row {
    id: root
    property alias textColor: label.color
    property alias text: label.text
    property string propertyName

    Label {id: label; anchors.verticalCenter: parent.verticalCenter}
    TextField {
        width: units.gu(10); hasClearButton: false; maximumLength: 6
        inputMask: "d00000"
        text: ""
        onTextChanged: {
            if (text.length > 0) {
                SurfaceManager[root.propertyName] = parseInt(text);
            } else {
                SurfaceManager[root.propertyName] = 0;
            }
        }
    }
}
