/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

Row {
    id: root
    spacing: units.gu(1)

    // to be set from outside
    property bool active: false
    property bool closeButtonShown: true

    signal close()
    signal minimize()
    signal maximize()

    MouseArea {
        id: closeWindowButton
        objectName: "closeWindowButton"
        hoverEnabled: true
        height: parent.height
        width: height
        onClicked: root.close()
        visible: root.closeButtonShown

        Rectangle {
            anchors.centerIn: parent
            width: units.gu(2)
            height: units.gu(2)
            radius: height / 2
            color: UbuntuColors.red
            visible: parent.containsMouse
        }
        Icon {
            width: height
            height: parent.height *.5
            anchors.centerIn: parent
            source: "graphics/window-close.svg"
            color: root.active ? "white" : UbuntuColors.slate
            keyColor: "black"
        }
    }

    MouseArea {
        id: minimizeWindowButton
        objectName: "minimizeWindowButton"
        hoverEnabled: true
        height: parent.height
        width: height
        onClicked: root.minimize()

        Rectangle {
            anchors.centerIn: parent
            width: units.gu(2)
            height: units.gu(2)
            radius: height / 2
            color: root.active ? UbuntuColors.graphite : UbuntuColors.ash
            visible: parent.containsMouse
        }
        Icon {
            width: height
            height: parent.height *.5
            anchors.centerIn: parent
            source: "graphics/window-minimize.svg"
            color: root.active ? "white" : UbuntuColors.slate
            keyColor: "black"
        }
    }

    MouseArea {
        id: maximizeWindowButton
        objectName: "maximizeWindowButton"
        hoverEnabled: true
        height: parent.height
        width: height
        onClicked: root.maximize()

        Rectangle {
            anchors.centerIn: parent
            width: units.gu(2)
            height: units.gu(2)
            radius: height / 2
            color: root.active ? UbuntuColors.graphite : UbuntuColors.ash
            visible: parent.containsMouse
        }
        Icon {
            width: height
            height: parent.height *.5
            anchors.centerIn: parent
            source: "graphics/window-maximize.svg"
            color: root.active ? "white" : UbuntuColors.slate
            keyColor: "black"
        }
    }
}
