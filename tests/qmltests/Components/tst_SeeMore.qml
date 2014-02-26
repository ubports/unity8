/*
 * Copyright 2014 Canonical Ltd.
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
import Ubuntu.Components 0.1
import "../../../qml/Components"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(10)
    color: Theme.palette.selected.background

    SeeMore {
        id: seeMore
        anchors.fill: parent
        more: false
    }

    UT.UnityTestCase {
        name: "SeeMoreTest"
        when: windowShown

        function test_interaction() {
            var seeMoreLabel = findChild(seeMore, "seeMoreLabel")
            var seeLessLabel = findChild(seeMore, "seeLessLabel")

            compare(seeMore.more, false)

            mouseClick(seeMoreLabel, seeMoreLabel.width / 2, seeMoreLabel.height / 2)
            compare(seeMore.more, true)

            mouseClick(seeLessLabel, seeLessLabel.width / 2, seeLessLabel.height / 2)
            compare(seeMore.more, false)
        }
    }
}
