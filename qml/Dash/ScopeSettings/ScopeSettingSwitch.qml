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

import QtQuick 2.2
import Ubuntu.Components 1.1

ScopeSetting {
    id: root
    implicitHeight: units.gu(6)

    Label {
        anchors {
            left: parent.left
            leftMargin: __margins
            right: control.left
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        text: widgetData.displayName
        elide: Text.ElideMiddle
        color: scopeStyle ? scopeStyle.foreground : "grey"
    }

    Switch {
        id: control
        objectName: "control"
        anchors {
            right: parent.right
            rightMargin: __margins
            verticalCenter: parent.verticalCenter
        }
        checked: widgetData.value

        onTriggered: root.triggered(checked)
    }
}
