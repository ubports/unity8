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
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

Row {
    id: root
    spacing: units.gu(0.5)

    signal close()
    signal minimize()
    signal maximize()

    Rectangle {
        objectName: "closeWindowButton"
        height: parent.height; width: height; radius: height / 2
        gradient: Gradient {
            GradientStop { color: "#F49073"; position: 0 }
            GradientStop { color: "#DF4F1C"; position: 1 }
        }
        border.width: units.dp(.5)
        border.color: "black"
        MouseArea { anchors.fill: parent; onClicked: root.close() }
    }
    Rectangle {
        objectName: "minimizeWindowButton"
        height: parent.height; width: height; radius: height / 2
        gradient: Gradient {
            GradientStop { color: "#92918C"; position: 0 }
            GradientStop { color: "#5E5D58"; position: 1 }
        }
        border.width: units.dp(.5)
        border.color: "black"
        MouseArea { anchors.fill: parent; onClicked: root.minimize() }
    }
    Rectangle {
        objectName: "maximizeWindowButton"
        height: parent.height; width: height; radius: height / 2
        gradient: Gradient {
            GradientStop { color: "#92918C"; position: 0 }
            GradientStop { color: "#5E5D58"; position: 1 }
        }
        border.width: units.dp(.5)
        border.color: "black"
        MouseArea { anchors.fill: parent; onClicked: root.maximize() }
    }
}
