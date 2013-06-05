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
import "../../../Greeter"
import Ubuntu.Components 0.1
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

    UT.UnityTestCase {
        name: "Clock"

        function test_customDate() {
            var dateObj = new Date("October 13, 1975 11:13:00")
            var dateString = Qt.formatDate(dateObj, Qt.DefaultLocaleLongDate)
            var timeString = Qt.formatTime(dateObj)

            clock.__timerInterval = 60000
            clock.__date = dateObj
            var dateLabel = findChild(clock, "dateLabel")
            compare(dateLabel.text, dateString, "Not the expected date")
            var timeLabel = findChild(clock, "timeLabel")
            compare(timeLabel.text, timeString, "Not the expected time")
        }

        function test_dateUpdate() {
            var dateObj = new Date("October 13, 1975 11:13:00")
            var dateString = Qt.formatDate(dateObj, Qt.DefaultLocaleLongDate)
            var timeString = Qt.formatTime(dateObj)

            clock.enabled = false
            compare(clock.__timerRunning, false, "Timer should not be running")
            clock.__date = dateObj
            clock.__timerInterval = 5
            wait(5) // spin event loop (only that would trigger the timer and reveal eventual bugs)
            var dateLabel = findChild(clock, "dateLabel")
            compare(dateLabel.text, dateString, "Not the expected date")
            var timeLabel = findChild(clock, "timeLabel")
            compare(timeLabel.text, timeString, "Not the expected time")

            clock.enabled = true
            compare(clock.__timerRunning, true, "Timer should be running")
            wait(0) // spin event loop to trigger the timer
            verify(dateLabel.text !== dateString)
            if (timeLabel.text == "11:13") wait(60000) // next test will fail at 11:13, wait 1 minute
            verify(timeLabel.text !== timeString)
        }

        function test_timerRunning() {
            // tests for clock.enabled property are already in test_dateUpdate()
            clock.opacity = 0.0
            compare(clock.__timerRunning, false, "Timer should not be running")
            clock.opacity = 1.0
            compare(clock.__timerRunning, true, "Timer should be running")
            clock.visible = false
            compare(clock.__timerRunning, false, "Timer should not be running")
            clock.visible = true
            compare(clock.__timerRunning, true, "Timer should be running")
        }
    }
}
