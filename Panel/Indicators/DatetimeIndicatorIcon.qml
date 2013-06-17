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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators

Indicators.IndicatorIcon {
    id: indicatorIcon

    width: timeLabel.width + units.gu(1)

    property alias label: timeLabel.text

    Label {
        id: timeLabel
        objectName: "timeLabel"
        color: "#f3f3e7"
        opacity: 0.8
        font.family: "Ubuntu"
        fontSize: "medium"
        anchors.centerIn: parent
        text: Qt.formatTime(timer.dateNow)
    }

    Timer {
        id: timer
        interval: 1000 * 10
        running: indicatorIcon.visible
        repeat: true
        triggeredOnStart: true
        property date dateNow

        onTriggered: dateNow = new Date
    }

    onActionStateChanged: {
        if (action == undefined || !action.valid) {
            return
        }

        if (action.state == undefined) {
            visible = false;
            return
        }

        indicatorIcon.visible = action.state[3]
    }
}
