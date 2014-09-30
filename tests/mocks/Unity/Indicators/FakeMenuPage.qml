/*
 * Copyright 2013 Canonical Ltd.
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
import Ubuntu.Components 1.1

Flickable {
    id: root
    objectName: "fakeMenuPlugin"

    property string identifier
    property color color: "transparent"

    Label {
        text: identifier
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: contents.top
            bottomMargin: units.gu(3)
        }
        color: Theme.palette.normal.foregroundText
        fontSize: "x-large"

    }

    Rectangle {
        id: contents
        color: root.color

        height: 150
        width: 150

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    // Make it compatible with the PluginItem interface
    function reset() {
        if (shell != undefined && shell.indicator_status != undefined) {
            shell.indicator_status[objectName].reset++;
        }
    }
}
