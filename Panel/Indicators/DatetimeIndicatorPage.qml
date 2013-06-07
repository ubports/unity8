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
            id: __time
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            text: ""
            color: "#f3f3e7"
            font.weight: Font.Light
            font.pixelSize: units.gu(6)
        }

        Label {
            id: __date

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                bottom: parent.bottom
                bottomMargin: units.gu(1.5)
            }
            text: ""
            color: "#f3f3e7"
            fontSize: "small"
        }
    }

    Timer {
        interval: 1000 * 60 // one minute
        running: true
        repeat: true
        onTriggered: updateTime();

        Component.onCompleted: updateTime();
    }

    function updateTime() {
        var dt = new Date()
        var time = Qt.formatTime(dt)
        var space = time.indexOf(" ")
        __time.text = time.substr(0, space > 0 ? space : 5)
        __date.text = Qt.formatDateTime(dt, "dddd,\ndd MMMM")
    }

    // Make it compatible with the PluginItem interface
    function start() {}
    function stop() {}
    function reset() {}
}
