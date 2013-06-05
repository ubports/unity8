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
import "../../../Components/Time.js" as TimeLocal

TestCase {
    name: "TimeLocal"

    property var readableDate

    function test_readableFromNow_dateUndefined() {
        readableDate = TimeLocal.readableFromNow()
        compare(readableDate, "", "readable date should have been null")
    }

    function test_readableFromNow_dateNaN() {
        readableDate = TimeLocal.readableFromNow("this is a string, not a date")
        compare(readableDate, "", "readable date should have been null")
    }

    function test_readableFromNow_justNow() {
        readableDate = TimeLocal.readableFromNow(new Date())
        compare(readableDate, "just now", "readable date should have been now")
    }

    function test_readableFromNow_nowNaN() {
        var fail = false
        try {
            TimeLocal.readableFromNow(new Date(), "this is a string, not a date")
        } catch (err) {
            fail = true
        } finally {
            compare(fail, true, "readable date should have thrown an exception")
        }
    }

    function cycleTime(diff, previous, next, units, endIterator) {
        var now = new Date()
        var time = now.getTime()
        readableDate = TimeLocal.readableFromNow(time - diff, now)
        compare(readableDate, previous, "different time predicted")
        readableDate = TimeLocal.readableFromNow(time + diff, now)
        compare(readableDate, next, "different time predicted")
        for (var i = 2; i < endIterator; i++) {
            var tmpDiff = i * diff
            readableDate = TimeLocal.readableFromNow(time - tmpDiff, now)
            compare(readableDate, i + " " + units + " ago", "different time predicted")
            readableDate = TimeLocal.readableFromNow(time + tmpDiff, now)
            compare(readableDate, "in " + i + " " + units, "different time predicted")
        }
    }

    function test_readableFromNow_seconds() {
        cycleTime(1000, "a second ago", "in a second", "seconds", 60)
    }

    function test_readableFromNow_minutes() {
        cycleTime(1000 * 60, "a minute ago", "in a minute", "minutes", 60)
    }

    function test_readableFromNow_hours() {
        cycleTime(1000 * 60 * 60, "an hour ago", "in an hour", "hours", 24)
    }

    function test_readableFromNow_days() {
        cycleTime(1000 * 60 * 60 * 24, "yesterday", "tomorrow", "days", 7)
    }

    function test_readableFromNow_weeks() {
        var now = new Date()
        for (var i = 7; i < 30; i++) {
            readableDate = TimeLocal.readableFromNow(now.getTime() - i * 1000 * 60 * 60 * 24, now)
            if (i < 14)
                compare(readableDate, "a week ago", "different time predicted")
            else if (i < 18)
                compare(readableDate, "about 2 weeks ago", "different time predicted")
            else if (i < 25)
                compare(readableDate, "about 3 weeks ago", "different time predicted")
            else
                compare(readableDate, "about 4 weeks ago", "different time predicted")
        }
        for (var i = 7; i < 30; i++) {
            readableDate = TimeLocal.readableFromNow(now.getTime() + i * 1000 * 60 * 60 * 24, now)
            if (i < 14)
                compare(readableDate, "in a week", "different time predicted")
            else if (i < 18)
                compare(readableDate, "in about 2 weeks", "different time predicted")
            else if (i < 25)
                compare(readableDate, "in about 3 weeks", "different time predicted")
            else
                compare(readableDate, "in about 4 weeks", "different time predicted")
        }
    }

    function test_readableFromNow_months() {
        cycleTime(1000 * 60 * 60 * 24 * 30.45, "a month ago", "in a month", "months", 12)
    }

    function test_readableFromNow_years() {
        cycleTime(1000 * 60 * 60 * 24 * 366, "a year ago", "in a year", "years", 5)
    }
}
