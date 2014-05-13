/*
 * Copyright 2013 Canonical Ltd.
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

import QtQuick 2.0
import QtTest 1.0
import ".."
import "../../../qml/Greeter"
import Ubuntu.Components 0.1
import QMenuModel 0.1
import Unity.Test 0.1 as UT

Rectangle {
    width: units.gu(60)
    height: units.gu(40)
    color: "black"

    Clock {
        id: clock
        anchors {
            top: parent.top
            topMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }
    }

    UnityMenuModel {
        id: menuModel
        modelData: [{
            "rowData": {
                "actionState": { "label": Qt.formatTime(new Date("October 13, 1975 11:13:00")) }
            }
        }]
    }

    UT.UnityTestCase {
        name: "Clock"

        function init() {
            var cachedModel = findChild(clock, "timeModel");
            verify(cachedModel !== undefined);
            cachedModel.model = menuModel;
        }

        function test_customDate() {
            var dateObj = new Date("October 13, 1975 11:13:00")
            var dateString = Qt.formatDate(dateObj, Qt.DefaultLocaleLongDate)
            var timeString = Qt.formatTime(dateObj)

            clock.currentDate = dateObj
            var dateLabel = findChild(clock, "dateLabel")
            compare(dateLabel.text, dateString, "Not the expected date")
            var timeLabel = findChild(clock, "timeLabel")
            compare(timeLabel.text, timeString, "Not the expected time")
        }

        function test_dateUpdate() {
            var dateObj = new Date("October 13, 1975 11:13:00")
            var dateString = Qt.formatDate(dateObj, Qt.DefaultLocaleLongDate)
            var timeString = Qt.formatTime(dateObj)

            clock.visible = false
            var timeModel = findInvisibleChild(clock, "timeModel")

            compare(timeModel.menuObjectPath, "", "Clock shouldn't be connected to Indicators when not visible.")

            clock.currentDate = dateObj

            var dateLabel = findChild(clock, "dateLabel")
            compare(dateLabel.text, dateString, "Not the expected date")
            var timeLabel = findChild(clock, "timeLabel")
            compare(timeLabel.text, timeString, "Not the expected time")

            clock.visible = true

            verify(timeModel.menuObjectPath != "", "Should be connected to Indicators.")
        }
    }
}
