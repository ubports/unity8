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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Ubo Riboni <ugo.riboni@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Flickable {
    id: page

    contentHeight: image.height

    Image {
        id: image
        anchors {
            left: parent.left
            right: parent.right
        }
        source: "../graphics/time_and_date@18.png"
        fillMode: Image.PreserveAspectFit
    }

    Item {
        anchors {
            top: parent.top
            topMargin: units.gu(5)
            left: parent.left
            right: parent.right
        }

        height: units.gu(30)

        Label {
            id: timeLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            text: ""
            color: Theme.palette.selected.backgroundText
            font.weight: Font.Light
            font.pixelSize: units.gu(6)
        }

        Label {
            id: dateLabel

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                bottom: parent.bottom
                bottomMargin: units.gu(1.5)
            }
            text: ""
            color: Theme.palette.selected.backgroundText
            fontSize: "small"
        }
    }

    Timer {
        interval: 1000 * 10 // 10 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateTime();
    }

    function updateTime() {
        var dt = new Date();
        var time = Qt.formatTime(dt);
        var space = time.indexOf(" ");
        timeLabel.text = time.substr(0, space > 0 ? space : 5);
        dateLabel.text = Qt.formatDateTime(dt, "dddd,\ndd MMMM");
    }

    // Make it compatible with the PluginItem interface
    function start() {}
    function stop() {}
    function reset() {}
}
