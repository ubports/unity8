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

AbstractStage {
    id: shimStage

    anchors.fill: parent

    Text {
        id: greeterModeText

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: units.gu(10)
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        text: "Shell is in \"greeter\" mode"
    }

    Text {
        anchors.centerIn: parent
        color: UbuntuColors.orange
        font.pointSize: units.gu(8)
        horizontalAlignment: Text.AlignHCenter
        text: "Shim \nStage"
    }
}
