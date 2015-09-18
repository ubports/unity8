/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.3
import QtTest 1.0
import Ubuntu.Components 1.1
import Dash 0.1

Rectangle {
    width: 500
    height: 300

    color: "red"

    CroppedImageMinimumSourceSize {
        id: cimss
        x: 100
        y: 100
        width: 100
        height: 100
        source: Qt.resolvedUrl("../../qmltests/Dash/artwork/music-player-design.png")
        asynchronous: true
    }

    TestCase {
        id: testCase
        name: "ScopeStyle"
        when: windowShown

        function test_croppedSource() {
            tryCompare(cimss.sourceSize, "width", 100);
            tryCompare(cimss.sourceSize, "height", 0);

            cimss.width = 40;
            tryCompare(cimss.sourceSize, "width", 0);
            tryCompare(cimss.sourceSize, "height", 100);

            cimss.width = 100;
            tryCompare(cimss.sourceSize, "width", 100);
            tryCompare(cimss.sourceSize, "height", 0);
        }
    }
}
