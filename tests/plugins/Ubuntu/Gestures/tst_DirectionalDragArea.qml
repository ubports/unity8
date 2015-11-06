/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
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
import Unity.Test 0.1

Rectangle {
    width: units.gu(60)
    height: units.gu(60)
    color: "white"

    Binding {
        target: MouseTouchAdaptor
        property: "enabled"
        value: true
    }

    MouseArea {
        id: mouseArea
        objectName: "mouseArea"
        anchors.fill: parent
        onClicked: {
            hpLauncher.reset()
            hnLauncher.reset()
            vpLauncher.reset()
            vnLauncher.reset()
        }
    }

    Item {
        id: baseItem
        objectName: "baseItem"
        width: parent.width
        height: parent.height

        // NB: Do not anchor it as we will move it programmatically from the test
        RightwardsLauncher {
            id: hpLauncher;
            width: parent.width
            height: parent.height
        }

        LeftwardsLauncher { id: hnLauncher; anchors.fill: parent }
        DownwardsLauncher { id: vpLauncher; anchors.fill: parent }
        UpwardsLauncher { id: vnLauncher; anchors.fill: parent }
    }

    Button {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: units.gu(1)

        text: "rotation: " + baseItem.rotation
        onClicked: {
            if (baseItem.rotation === 0.0) {
                baseItem.rotation = 90.0
            } else {
                baseItem.rotation = 0.0
            }
        }
    }
}
