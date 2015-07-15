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

import QtQuick 2.4
import QtTest 1.0
import ".."
import "../../../qml/Greeter"
import Ubuntu.Components 1.3
import Unity.Indicators 0.1 as Indicators
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

    function updateDatetimeModelTime(label) {
        Indicators.UnityMenuModelCache.setCachedModelData("/com/canonical/indicator/datetime/phone",
            [{
                "rowData": {
                    "actionState": { "label": label }
                }
            }]);
    }

    UT.UnityTestCase {
        name: "Clock"
        when: windowShown

        function init() {
            updateDatetimeModelTime(Qt.formatTime(new Date("October 13, 1975 12:14:00")));
            clock.visible = true;
        }

        // Test that the date portion of the clock updates with custom value.
        // Time portion is controlled by indicators
        function test_updateDate() {
            var dateLabel = findChild(clock, "dateLabel");
            var timeLabel = findChild(clock, "timeLabel");

            var timeString = Qt.formatTime(new Date("October 13, 1975 12:14:00"));

            // initial date.
            var dateObj = new Date("October 13, 1975 11:13:00");
            var dateString = Qt.formatDate(dateObj, Qt.DefaultLocaleLongDate);
            clock.currentDate = dateObj;

            compare(dateLabel.text, dateString, "Not the expected date");
            compare(timeLabel.text, timeString, "Time should come from indicators");

            // update date.
            var dateObj2 = new Date("October 14, 1976 13:15:00");
            var dateString2 = Qt.formatDate(dateObj2, Qt.DefaultLocaleLongDate);
            clock.currentDate = dateObj2;

            compare(dateLabel.text, dateString2, "Not the expected date");
            compare(timeLabel.text,timeString, "Time should come from indicators");
        }

        // Test that the date portion of the clock updates with custom value.
        // Time portion is controlled by indicators
        function test_updateTime() {
            var timeLabel = findChild(clock, "timeLabel");

            var timeString1 = Qt.formatTime(new Date("October 13, 1975 11:15:00"));
            var timeString2 = Qt.formatTime(new Date("October 14, 1976 12:16:00"));

            updateDatetimeModelTime(timeString1);
            compare(timeLabel.text, timeString1, "Time should come from indicators");

            updateDatetimeModelTime(timeString2);
            compare(timeLabel.text, timeString2, "Time should come from indicators");
        }

        function test_indicatorDisconnect() {
            clock.visible = false
            var timeModel = findInvisibleChild(clock, "timeModel")
            compare(timeModel.menuObjectPath, "", "Clock shouldn't be connected to Indicators when not visible.")

            clock.visible = true
            verify(timeModel.menuObjectPath !== "", "Should be connected to Indicators.")
        }
    }
}
