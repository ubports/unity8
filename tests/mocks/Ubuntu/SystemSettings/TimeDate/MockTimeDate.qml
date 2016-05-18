/*
 * Copyright (C) 2015 Canonical, Ltd.
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

Item {
    id: root
    readonly property alias timeZone: d.timeZone
    readonly property alias timeZoneName: d.timeZoneName

    signal timeZoneChangedCalled(string tz, string name) // only in mock

    function setTimeZone(tz, name) {
        d.timeZone = tz;
        d.timeZoneName = name;
        timeZoneChangedCalled(tz, name);
    }

    QtObject {
        id: d
        property string timeZone: "Europe/Prague"
        property string timeZoneName: "Prague"
    }
}
