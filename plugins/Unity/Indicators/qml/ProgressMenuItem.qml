/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

MenuItem {
    id: progressMenu
    property alias value : progressBar.value

    // TODO: Replace this with the official ProgressBar component as soon as
    // it is available. For now, this rebuilds the Mockup as close as possible.
    UbuntuShape {
        id: progressBar
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
        }
        height: units.gu(4)
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"

        property int minimumValue: 0
        property int maximumValue: 100
        property int value: 50

        UbuntuShape {
            anchors.fill: parent
            anchors.rightMargin: parent.width - (parent.width * parent.value / parent.maximumValue)
            color: "#c94212"
        }

        Label {
            anchors.centerIn: parent
            text: parent.value + " %"
            fontSize: "medium"
            color: "#e8e1d0"
        }
    }

    MenuActionBinding {
        actionGroup: progressMenu.actionGroup
        action: menu ? menu.action : ""
        target: progressBar
        property: "value"
    }
}
