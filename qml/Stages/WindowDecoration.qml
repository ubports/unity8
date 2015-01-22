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

import QtQuick 2.3
import Ubuntu.Components 1.1
import "../Components"

Item {
    id: root
    clip: true

    property alias title: titleLabel.text
    property bool active: false

    signal close()
    signal minimize()
    signal maximize()

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: -radius
        radius: units.gu(.5)
        gradient: Gradient {
            GradientStop { color: "#626055"; position: 0 }
            GradientStop { color: "#3C3B37"; position: 1 }
        }
    }

    Row {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: units.gu(0.7) }
        spacing: units.gu(1)
        opacity: root.active ? 1 : 0.5

        WindowControlButtons {
            height: parent.height
            onClose: root.close();
            onMinimize: root.minimize();
            onMaximize: root.maximize();
        }

        Label {
            id: titleLabel
            color: "#DFDBD2"
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            fontSize: "small"
            font.bold: true
        }
    }
}
