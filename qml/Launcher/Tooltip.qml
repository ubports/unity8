/*
 * Copyright (C) 2016 Canonical, Ltd.
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

UbuntuShape {
    id: root

    // This property holds the delay (milliseconds) after which the tool tip is shown.
    // A tooltip with a negative delay is shown immediately. The default value is UbuntuAnimation.SlowDuration.
    property alias delay: delayTimer.interval

    // This property holds the text shown on the tool tip.
    property alias text: label.text

    aspect: UbuntuShape.Flat
    color: theme.palette.normal.background
    width: label.implicitWidth + units.gu(4)
    height: label.implicitHeight + units.gu(2)

    Behavior on opacity {
        UbuntuNumberAnimation {
            duration: UbuntuAnimation.BriskDuration
        }
    }

    Binding on opacity {
        when: !visible
        value: 0
    }

    Timer {
        id: delayTimer
        running: root.visible
        triggeredOnStart: true
        interval: UbuntuAnimation.SlowDuration
        onTriggered: root.opacity = (running ? .0 : .95)
    }

    Image {
        anchors {
            right: parent.left
            rightMargin: -units.dp(4)
            verticalCenter: parent.verticalCenter
        }
        source: "graphics/quicklist_tooltip.png"
        rotation: 90
    }

    Label {
        id: label
        anchors.centerIn: parent
        color: theme.palette.normal.backgroundText
    }
}